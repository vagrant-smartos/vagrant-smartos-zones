module Vagrant
  module Smartos
    module Zones
      module Action
        class ZoneCreate
          def initialize(app, env)
            @app = app
          end

          def call(env)
            machine = env[:machine]
            guest = machine.guest

            if guest.capability?(:zone_create)
              guest.capability(:zone_create)
            end

            @app.call(env)
          end
        end
      end
    end
  end
end
