require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Stop
            def self.zone_stop(machine)
              if zone_valid?(machine)
                return unless zone_exists?(machine)

                stop_zone(machine)
              end
            end

            def self.stop_zone(machine)
              name = machine.config.zone.name
              machine.ui.info "Stopping zone #{name}"
              Util::ZoneInfo.new(machine).stop(name)
            end

            def self.zone_exists?(machine)
              name = machine.config.zone.name
              sudo = machine.config.smartos.suexec_cmd

              machine.communicate.gz_test("#{sudo} vmadm list -H | awk '{print $5}' | grep #{name}")
            end

            def self.zone_valid?(machine)
              machine.config.zone && machine.config.zone.image && machine.config.zone.name
            end
          end
        end
      end
    end
  end
end
