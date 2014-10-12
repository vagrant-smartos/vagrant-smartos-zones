require 'vagrant/smartos/zones/cap/zone/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Stop < Base
            cap_method :zone__stop

            def execute
              return unless zone_valid?
              return unless zone_exists?

              stop_zone
            end

            def stop_zone
              return unless zone.running?
              name = machine.config.zone.name
              ui.info "Stopping zone #{name}"
              zone_info.stop(name)
            end
          end
        end
      end
    end
  end
end
