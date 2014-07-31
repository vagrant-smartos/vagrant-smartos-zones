require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Cap
        class CreateZoneUsers
          def self.create_zone_users(machine)
            ui = machine.ui
            zone = Util::ZoneInfo.new(machine).show(machine.config.zone.name)
            ui.info "Creating users in zone #{zone.name} #{zone.uuid}"

            machine.communicate.execute("pfexec zlogin #{zone.uuid} groupadd vagrant")
            machine.communicate.execute("pfexec zlogin #{zone.uuid} useradd -m -s /bin/bash -G vagrant vagrant")
            machine.communicate.execute("pfexec zlogin #{zone.uuid} usermod -P\\'Primary Administrator\\' vagrant")
            machine.communicate.execute("pfexec zlogin #{zone.uuid} sed -i -e \\'s@root:.*@root:\\$5\\$90x8mAeX\\$SKKNEjeztV.ruPBNf/E5y3xqGkwDv9A5KNP2S89GuB.:16151::::::@\\' /etc/shadow")
            machine.communicate.execute("pfexec zlogin #{zone.uuid} sed -i -e \\'s@vagrant:.*@vagrant:\\$5\\$UzQ1rHU/\\$o67DYOyHOOabzJt.6DwgZP2qCGoAO7aVel2bgkuIwL7:16158::::::@\\' /etc/shadow")
            machine.communicate.execute("pfexec zlogin #{zone.uuid} cp /opt/local/etc/sudoers.d/admin /opt/local/etc/sudoers.d/vagrant")
            machine.communicate.execute("pfexec zlogin #{zone.uuid} sed -i '' \\'s@admin@vagrant@\\' /opt/local/etc/sudoers.d/vagrant")
          end
        end
      end
    end
  end
end

