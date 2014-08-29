require 'vagrant/smartos/zones/models/zone_group'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneGroup
          attr_reader :machine, :zone

          def initialize(machine, zone)
            @machine = machine
            @zone = zone
          end

          def find(group)
            Models::ZoneGroup.new.tap do |g|
              g.name = group
              machine.communicate.execute("#{sudo} zlogin #{zone.uuid} gid -g #{group}") do |type, output|
                g.gid = output.chomp
              end
            end
          end

          private

          def sudo
            machine.config.smartos.suexec_cmd
          end
        end
      end
    end
  end
end
