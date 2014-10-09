require 'vagrant/smartos/zones/cap/zone/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Stop < Base
            def self.zone__stop(machine)
              if zone_valid?(machine)
                return unless zone_exists?(machine)

                stop_zone(machine)
              end
            end

            def self.stop_zone(machine)
              return unless self.zone(machine).running?
              name = machine.config.zone.name
              machine.ui.info "Stopping zone #{name}"
              self.zone_info(machine).stop(name)
            end
          end
        end
      end
    end
  end
end
