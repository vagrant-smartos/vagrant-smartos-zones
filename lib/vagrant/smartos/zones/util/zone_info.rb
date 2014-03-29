require 'vagrant/smartos/zones/models/zone'

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
            machine.communicate.execute("#{sudo} vmadm lookup -j") do |type, output|
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
            if machine.guest.capability?(:zone_create)
              machine.guest.capability(:zone_create)
              show(name)
            end
          end

          def destroy(name)
            zone = show(name)
            machine.communicate.execute("#{sudo} vmadm delete #{zone.uuid}")
            zone.state = 'deleted'
            zone
          end

          def show(name)
            zone = {}
            machine.communicate.execute("#{sudo} vmadm lookup -j -o uuid,alias,state,image_uuid,brand alias=#{machine.config.zone.name}") do |type, output|
              zone.merge!(JSON.parse(output).first)
            end

            Models::Zone.new.tap do |z|
              z.name = zone['alias']
              z.uuid = zone['uuid']
              z.brand = zone['brand']
              z.state = zone['state']
              z.image = zone['image_uuid']
            end
          end

          def start(name)
            zone = show(name)
            machine.communicate.execute("#{sudo} vmadm start #{zone.uuid}")
            zone
          end

          def stop(name)
            zone = show(name)
            machine.communicate.execute("#{sudo} vmadm stop #{zone.uuid}")
            zone
          end

          def sudo
            machine.config.smartos.suexec_cmd
          end
        end
      end
    end
  end
end
