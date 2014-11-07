require 'vagrant/smartos/zones/models/zone'
require 'vagrant/smartos/zones/util/zone_json'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneInfo
          attr_reader :machine

          def initialize(machine)
            @machine = machine
          end

          def list
            zones = []
            with_gz("#{sudo} vmadm lookup -j") do |output|
              zone_data = JSON.parse(output)
              zone_data.each do |zone|
                zones << [zone['alias'].to_s.ljust(25),
                          zone['zone_state'].to_s.ljust(10),
                          zone['zonename']].join(' ')
              end
            end

            zones
          end

          def create(name)
            machine.ui.info "Creating zone #{machine.config.zone.name} with image #{machine.config.zone.image}"
            with_gz("echo '#{zone_json}' | #{sudo} vmadm create")
            zone = show(name)
            create_zone_users(zone)
            zone
          end

          def create_zone_users(zone)
            # add vagrant user/group
            with_gz("#{sudo} zlogin #{zone.uuid} groupadd vagrant")
            with_gz("#{sudo} zlogin #{zone.uuid} useradd -m -s /bin/bash -G vagrant vagrant")
            with_gz("#{sudo} zlogin #{zone.uuid} usermod -P\\'Primary Administrator\\' vagrant")

            # set vagrant/root password to 'vagrant'
            with_gz("#{sudo} zlogin #{zone.uuid} sed -i -e \\'s@root:.*@root:\\$5\\$90x8mAeX\\$SKKNEjeztV.ruPBNf/E5y3xqGkwDv9A5KNP2S89GuB.:16151::::::@\\' /etc/shadow")
            with_gz("#{sudo} zlogin #{zone.uuid} sed -i -e \\'s@vagrant:.*@vagrant:\\$5\\$UzQ1rHU/\\$o67DYOyHOOabzJt.6DwgZP2qCGoAO7aVel2bgkuIwL7:16158::::::@\\' /etc/shadow")

            # configure sudoers
            with_gz("#{sudo} zlogin #{zone.uuid} cp /opt/local/etc/sudoers.d/admin /opt/local/etc/sudoers.d/vagrant")
            with_gz("#{sudo} zlogin #{zone.uuid} sed -i -e \\'s@admin@vagrant@\\' /opt/local/etc/sudoers.d/vagrant")

            # add vagrant public key to authorized_keys
            with_gz("#{sudo} zlogin #{zone.uuid} mkdir -p /home/vagrant/.ssh")
            with_gz("#{sudo} zlogin #{zone.uuid} touch /home/vagrant/.ssh/authorized_keys")
            with_gz(%(#{sudo} zlogin #{zone.uuid} 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys'))
            with_gz("#{sudo} zlogin #{zone.uuid} chown -R vagrant:other /home/vagrant/.ssh")
            with_gz("#{sudo} zlogin #{zone.uuid} chmod 600 /home/vagrant/.ssh/authorized_keys")
          end

          def destroy(name)
            zone = show(name)
            with_gz("#{sudo} vmadm delete #{zone.uuid}")
            zone.state = 'deleted'
            zone
          end

          def show(name)
            zone_name = name || machine.config.zone.name
            zone = {}
            with_gz("#{sudo} vmadm lookup -j -o uuid,alias,state,image_uuid,brand alias=#{zone_name}") do |output|
              zone.merge!(JSON.parse(output).first)
            end

            Models::Zone.from_hash(zone)
          end

          def start(name)
            zone = show(name)
            with_gz("#{sudo} vmadm start #{zone.uuid}")
            zone
          end

          def stop(name)
            zone = show(name)
            with_gz("#{sudo} vmadm stop #{zone.uuid}")
            zone
          end

          def update(name)
            machine.ui.info "Updating zone #{name}..."
            zone = show(name)
            with_gz("echo '#{zone_json}' | #{sudo} vmadm update #{zone.uuid}")
            zone
          end

          private

          def sudo
            machine.config.smartos.suexec_cmd
          end

          def with_gz(command)
            machine.communicate.gz_execute(command) do |_type, output|
              yield output if block_given?
            end
          end

          def zone_json
            Util::ZoneJson.new(machine).to_json
          end
        end
      end
    end
  end
end
