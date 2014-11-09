require 'vagrant/smartos/zones/action/helper'

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
            app.call(env)
            env[:ui].info "Checking if machine supports zones: #{zones_supported? ? 'yes' : 'no'}"
            guest.capability(:imgadm_import) if zones_supported?
          end
        end
      end
    end
  end
end
