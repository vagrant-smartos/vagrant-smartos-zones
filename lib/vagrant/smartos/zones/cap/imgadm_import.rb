module Vagrant
  module Smartos
    module Zones
      module Cap
        class ImgadmImport
          def self.imgadm_import(machine)
            ui = machine.ui
            sudo = machine.config.smartos.suexec_cmd
            image = machine.config.zone.image

            if !machine.communicate.test("#{sudo} imgadm get #{image}")
              ui.info "Global zone does not have #{image} installed"
              ui.info "Importing..."
              machine.communicate.execute("#{sudo} imgadm import #{image}")
            else
              ui.info "Global zone already has #{image} installed"
            end
          end
        end
      end
    end
  end
end
