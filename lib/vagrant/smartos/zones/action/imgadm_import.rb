require_relative 'helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        class ImgadmImport
          include Helper

          def initialize(app, env)
            @app = app
            @env = env
          end

          def call(env)
            env[:ui].info "Checking if machine supports zones: #{zones_supported? ? 'yes' : 'no'}"

            if zones_supported?
              guest.capability(:imgadm_import)
            end

            app.call(env)
          end
        end
      end
    end
  end
end
