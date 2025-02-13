# frozen_string_literal: true

#
# Cookbook:: aws-parallelcluster-config
# Recipe:: enable_chef_error_handler
#
# Copyright:: 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

if node["cluster"]["node_type"] == "HeadNode"
  chef_handler 'WriteChefError::WriteHeadNodeChefError' do
    type exception: true
    action :enable
  end
end

include_recipe "aws-parallelcluster-slurm::enable_chef_error_handler" if node["cluster"]["scheduler"] == "slurm"
