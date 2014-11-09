require 'vagrant/smartos/zones/action/helper'

# This action installs a vnic in the global zone, used by
# local zones. The executed code needs to happen after
# networks have been configured in the global zone.
#
# Zone creation is hooked onto this 
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
            app.call(env)
            guest.capability(:create_gz_vnic) if zones_supported?
          end
        end
      end
    end
  end
end
