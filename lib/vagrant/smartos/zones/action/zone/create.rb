require 'vagrant/smartos/zones/action/helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        module Zone
          class Create
            include Helper

            def initialize(app, env)
              @app = app
              @env = env
            end

            def call(env)

              if zones_supported?
                guest.capability(:zone__create)
              end

              app.call(env)
            end
          end
        end
      end
    end
  end
end
