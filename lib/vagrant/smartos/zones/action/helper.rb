module Vagrant
  module Smartos
    module Zones
      module Action
        module Helper

          private

          def app
            @app
          end

          def env
            @env
          end

          def machine
            @machine ||= env[:machine]
          end

          def guest
            @guest ||= machine.guest
          end

          def zones_supported?
            @zones_supported ||= guest.capability?(:imgadm_import)
          end

          def zone_configured?
            !!machine.config.zone.name
          end
        end
      end
    end
  end
end

