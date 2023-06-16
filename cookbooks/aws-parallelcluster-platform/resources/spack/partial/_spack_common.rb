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

  node.default['cluster']['spack_user'] = new_resource.spack_user
  node.default['cluster']['spack_root'] = new_resource.spack_root
  node_attributes "dump node attributes"
end
