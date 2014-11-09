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
              app.call(env)
              guest.capability(:zone__create) if zones_supported?
            end
          end
        end
      end
    end
  end
end
