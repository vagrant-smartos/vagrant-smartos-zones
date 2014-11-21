require 'vagrant/smartos/zones/models/zone'
require 'vagrant/smartos/zones/util/global_zone/helper'
require 'vagrant/smartos/zones/util/zone_group'
require 'vagrant/smartos/zones/util/zone_json'
require 'vagrant/smartos/zones/util/zone_user'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneInfo
          include GlobalZone::Helper

          attr_reader :machine

          ROOT_PASSWORD = '\$5\$90x8mAeX\$SKKNEjeztV.ruPBNf/E5y3xqGkwDv9A5KNP2S89GuB.'
          VAGRANT_PASSWORD = '\$5\$UzQ1rHU/\$o67DYOyHOOabzJt.6DwgZP2qCGoAO7aVel2bgkuIwL7'

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

          def create_zone_users(zone)
            create_zone_vagrant_user(zone)
            configure_zone_passwords(zone)
          end

          def create_zone_vagrant_user(zone)
            Util::ZoneGroup.new(machine, zone).create('vagrant')
            Util::ZoneUser.new(machine, zone).create('vagrant', 'vagrant', 'Primary Administrator')
          end

          def configure_zone_passwords(zone)
            overwrite_password(zone, 'root', ROOT_PASSWORD, '16151')
            overwrite_password(zone, 'vagrant', VAGRANT_PASSWORD, '16158')
          end

          def overwrite_password(zone, user, pw, ts)
            zlogin(zone, "sed -i -e \\'s@#{user}:.*@#{user}:#{pw}:#{ts}::::::@\\' /etc/shadow")
          end

          def zone_json
            Util::ZoneJson.new(machine).to_json
          end
        end
      end
    end
  end
end
