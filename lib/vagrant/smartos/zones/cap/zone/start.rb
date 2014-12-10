require 'vagrant/smartos/zones/cap/zone/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Start < Base
            cap_method :zone__start

            def execute
              return unless zone_valid?
              return unless zone_exists?

              start_zone
            end

            def start_zone
              return if zone.running?
              name = machine.config.zone.name
              ui.info "Starting zone #{name}"
              zone.start
            end
          end
        end
      end
    end
  end
end
