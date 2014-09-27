require_relative 'helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        class CreateGZVnic
          include Helper

          def initialize(app, env)
            @app = app
            @env = env
          end

          def call(env)

            if zones_supported?
              guest.capability(:create_gz_vnic)
            end

            app.call(env)
          end
        end
      end
    end
  end
end
