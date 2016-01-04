# This Vagrantfile exists for the purposes of development on
# this plugin.
Vagrant.configure('2') do |config|
  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
  end

  config.ssh.insert_key = false

  # See https://vagrantcloud.com/livinginthepast for SmartOS boxes
  config.vm.box = 'livinginthepast/smartos-base64'
  config.vm.communicator = 'smartos'

  # livinginthepast boxes include a default platform_image. Set
  # here to download/use a different image.
  config.global_zone.platform_image = 'latest'

  config.zone.name = 'base64'
  config.zone.brand = 'joyent'
  config.zone.image = '842e6fa6-6e9b-11e5-8402-1b490459e334'
  config.zone.memory = 1536
  config.zone.disk_size = 5

  # config.zone.name = 'lx'
  # config.zone.brand = 'lx'
  # config.zone.image = 'b7493690-f019-4612-958b-bab5f844283e'
  # config.zone.memory = 1536
  # config.zone.disk_size = 5
end
