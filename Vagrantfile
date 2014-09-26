Vagrant.configure('2') do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 5120
  end

  # See https://vagrantcloud.com/livinginthepast for SmartOS boxes
  config.vm.box = 'livinginthepast/smartos-base64'

  # livinginthepast boxes include a default platform_image. Set
  # here to download/use a different image.
  config.global_zone.platform_image = '20140919T024804Z'

  config.zone.name = 'base64'
  config.zone.brand = 'joyent'
  config.zone.image = 'd34c301e-10c3-11e4-9b79-5f67ca448df0'
  config.zone.memory = 4608
  config.zone.disk_size = 5
end
