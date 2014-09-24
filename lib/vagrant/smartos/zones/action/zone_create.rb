require_relative 'helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        class ZoneCreate
          include Helper

          def initialize(app, env)
            @app = app
            @env = env
          end

          def call(env)

            if zones_supported?
              guest.capability(:zone_create)
            end

            app.call(env)
          end
        end
      end
    end
  end
end
