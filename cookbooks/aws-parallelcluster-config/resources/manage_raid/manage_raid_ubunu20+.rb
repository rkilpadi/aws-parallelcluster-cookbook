provides :manage_raid, platform: 'ubuntu' do |node|
  node['platform_version'].to_i >= 20
end

use 'partial/_raid_configuration'

action_class do
  def raid_superblock_version
    '1.2'
  end
end
