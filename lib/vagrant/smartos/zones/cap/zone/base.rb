require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Base
            def self.zone_exists?(machine)
              name = machine.config.zone.name
              sudo = machine.config.smartos.suexec_cmd

              machine.communicate.gz_test("#{sudo} vmadm list -H | awk '{print $5}' | grep #{name}")
            end

            def self.zone_valid?(machine)
              machine.config.zone && machine.config.zone.image && machine.config.zone.name
            end

            def self.zone_info(machine)
              @zone_info ||= Util::ZoneInfo.new(machine)
            end

            def self.zone(machine)
              @zone ||= zone_info(machine).show(machine.config.zone.name)
            end
          end
        end
      end
    end
  end
end
