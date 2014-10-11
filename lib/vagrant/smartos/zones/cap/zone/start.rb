require 'vagrant/smartos/zones/cap/zone/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Start < Base
            def self.zone__start(machine)
              if zone_valid?(machine)
                return unless zone_exists?(machine)

                start_zone(machine)
              end
            end

            def self.start_zone(machine)
              return if zone(machine).running?
              name = machine.config.zone.name
              machine.ui.info "Starting zone #{name}"
              zone_info(machine).start(name)
            end
          end
        end
      end
    end
  end
end
