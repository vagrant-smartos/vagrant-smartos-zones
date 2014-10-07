require 'vagrant/smartos/zones/action/helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        module ZoneGate
          class Enable
            include Helper

            def initialize(app, env)
              @app = app
              @env = env
            end

            def call(env)

              if single_zone_mode?
                guest.capability(:zone_gate_enable)
              end

              app.call(env)
            end
          end
        end
      end
    end
  end
end
