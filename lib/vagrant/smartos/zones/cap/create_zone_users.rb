require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Cap
        class CreateZoneUsers
          # rubocop:disable Metrics/LineLength, Metrics/MethodLength
          def self.create_zone_users(machine)
            ui = machine.ui
            sudo = machine.config.smartos.suexec_cmd
            zone = Util::ZoneInfo.new(machine).show(machine.config.zone.name)
            ui.info "Creating users in zone #{zone.name} #{zone.uuid}"

            # add vagrant user/group
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} groupadd vagrant")
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} useradd -m -s /bin/bash -G vagrant vagrant")
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} usermod -P\\'Primary Administrator\\' vagrant")

            # set vagrant/root password to 'vagrant'
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} sed -i -e \\'s@root:.*@root:\\$5\\$90x8mAeX\\$SKKNEjeztV.ruPBNf/E5y3xqGkwDv9A5KNP2S89GuB.:16151::::::@\\' /etc/shadow")
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} sed -i -e \\'s@vagrant:.*@vagrant:\\$5\\$UzQ1rHU/\\$o67DYOyHOOabzJt.6DwgZP2qCGoAO7aVel2bgkuIwL7:16158::::::@\\' /etc/shadow")

            # configure sudoers
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} cp /opt/local/etc/sudoers.d/admin /opt/local/etc/sudoers.d/vagrant")
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} sed -i -e \\'s@admin@vagrant@\\' /opt/local/etc/sudoers.d/vagrant")

            # add vagrant public key to authorized_keys
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} mkdir -p /home/vagrant/.ssh")
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} touch /home/vagrant/.ssh/authorized_keys")
            machine.communicate.gz_execute(%(#{sudo} zlogin #{zone.uuid} 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys'))
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} chown -R vagrant:other /home/vagrant/.ssh")
            machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} chmod 600 /home/vagrant/.ssh/authorized_keys")
          end
        end
      end
    end
  end
end
