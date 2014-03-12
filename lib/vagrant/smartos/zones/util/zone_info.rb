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

          def show(name)
            zone = {}
            machine.communicate.execute("#{sudo} vmadm lookup -j -o uuid,alias,state,image_uuid,brand alias=#{machine.config.zone.name}") do |type, output|
              zone.merge!(JSON.parse(output).first)
            end

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
