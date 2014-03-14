module Vagrant
  module Smartos
    module Zones
      module Action
        class ImgadmImport
          attr_accessor :app, :guest
          def initialize(app, env)
            @app = app
          end

          def call(env)
            @app.call(env)

            machine = env[:machine]
            @guest = machine.guest

            env[:ui].info "Checking if machine supports zones: #{zones_supported? ? 'yes' : 'no'}"
            if zones_supported?
              guest.capability(:imgadm_import)
            end
          end

          private

          def zones_supported?
            @zones_supported ||= guest.capability?(:imgadm_import)
          end
        end
      end
    end
  end
end
