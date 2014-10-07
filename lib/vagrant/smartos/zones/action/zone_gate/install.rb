require 'vagrant/smartos/zones/action/helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        module ZoneGate
          class Install
            include Helper

            def initialize(app, env)
              @app = app
              @env = env
            end

            def call(env)

              if zones_supported?
                guest.capability(:zone_gate_install)
              end

              app.call(env)
            end
          end
        end
      end
    end
  end
end
