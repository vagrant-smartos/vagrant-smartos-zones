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
            return unless machine.guest.capability?(:zone_create)

            machine.guest.capability(:zone_create)
            show(name)
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

          private

          def sudo
            machine.config.smartos.suexec_cmd
          end

          def with_gz(command)
            machine.communicate.gz_execute(command) do |_type, output|
              yield output if block_given?
            end
          end
        end
      end
    end
  end
end
