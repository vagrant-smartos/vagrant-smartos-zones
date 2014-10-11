require 'vagrant/smartos/zones/action/helper'

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
            guest.capability(:create_gz_vnic) if zones_supported?

            app.call(env)
          end
        end
      end
    end
  end
end
