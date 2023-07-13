# frozen_string_literal: true

# Copyright:: 2013-2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

unified_mode true
default_action :install_spack

property :spack_user, String, required: false,
         default: node['cluster']['cluster_user']

property :spack_root, String, required: false,
         default: "/home/#{node['cluster']['cluster_user']}/spack"

action :install_spack do
  return if on_docker?

  node.default['cluster']['spack']['user'] = new_resource.spack_user
  node.default['cluster']['spack']['root'] = new_resource.spack_root
  node_attributes 'dump node attributes'

  package_repos 'update package repos'

  install_packages 'install spack dependencies' do
    packages dependencies
    action :install
  end

  git new_resource.spack_root do
    repository 'https://github.com/spack/spack'
    user new_resource.spack_user
    group new_resource.spack_user
  end

  template '/etc/profile.d/spack.sh' do
    cookbook 'aws-parallelcluster-platform'
    source 'spack/spack.sh.erb'
    owner 'root'
    group 'root'
    mode  '0755'
    variables(spack_root: new_resource.spack_root)
  end

  spack = "#{new_resource.spack_root}/bin/spack"
  spack_configs_dir = "#{new_resource.spack_root}/etc/spack"
  arch_target = `#{spack} arch -t`.strip

  # Find libfabric version to be used in package configs
  libfabric_version = nil
  ::File.open(libfabric_path).each do |line|
    if line.include?('Version:')
      libfabric_version = line.split[1].strip
      break
    end
  end

  # Pull architecture dependent package config
  begin
    template "#{spack_configs_dir}/packages.yaml" do
      cookbook 'aws-parallelcluster-platform'
      source "spack/packages-#{arch_target}.yaml.erb"
      owner new_resource.spack_user
      group new_resource.spack_user
      variables(libfabric_version: libfabric_version)
    end
  rescue Chef::Exceptions::FileNotFound
    Chef::Log.warn "Could not find template for #{arch_target}"
  end

  template "#{spack_configs_dir}/mirrors.yaml" do
    cookbook 'aws-parallelcluster-platform'
    source "spack/mirrors.yaml.erb"
    owner new_resource.spack_user
    group new_resource.spack_user
    variables(arch_target: arch_target)
  end

  cookbook_file "#{spack_configs_dir}/modules.yaml" do
    cookbook 'aws-parallelcluster-platform'
    source 'spack/modules.yaml'
    owner new_resource.spack_user
    group new_resource.spack_user
    mode '0755'
  end

  bash 'setup Spack' do
    user new_resource.spack_user
    environment({ "HOME" => "/home/#{new_resource.spack_user}" })
    code <<-SPACK
      source #{new_resource.spack_root}/share/spack/setup-env.sh
      #{spack} compiler add --scope site
      #{spack} external find --scope site
      #{spack} tags build-tools | xargs -I {} #{spack} config --scope site rm packages:{}
      #{spack} buildcache keys --install --trust
    SPACK
  end
end
