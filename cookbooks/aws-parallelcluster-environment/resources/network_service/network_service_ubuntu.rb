# frozen_string_literal: true

#
# Copyright:: 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License
provides :network_service, platform: 'ubuntu'

unified_mode true
default_action :restart

use 'partial/_network_service'

action :reload do
  execute "apply network configuration" do
    command "netplan apply"
    timeout 60
  end unless on_docker?
end

def network_service_name
  'systemd-resolved'
end
