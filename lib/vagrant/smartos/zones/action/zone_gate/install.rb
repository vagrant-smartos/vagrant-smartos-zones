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
              guest.capability(:zone_gate_install) if zones_supported?

              app.call(env)
            end
          end
        end
      end
    end
  end
end
