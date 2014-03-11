module Vagrant
  module Smartos
    module Zones
      module Action
        class ImgadmImport
          def initialize(app, env)
            @app = app
          end

          def call(env)
            @app.call(env)

            machine = env[:machine]
            guest = machine.guest

            env[:ui].info "Checking if machine supports zones"
            if guest.capability?(:imgadm_import)
              guest.capability(:imgadm_import)
            end

            #binding.pry

            #sudo = machine.config.smartos.suexec_cmd
            #image = machine.config.zone.image

            #if !machine.communicate.test("#{sudo} imgadm get #{image}")
              #@logger.info "Importing zone image #{image}"
              #machine.communicate.execute("#{sudo} imgadm import #{image}")
            #end
          end
        end
      end
    end
  end
end
