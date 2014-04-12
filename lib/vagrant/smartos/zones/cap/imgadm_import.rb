module Vagrant
  module Smartos
    module Zones
      module Cap
        class ImgadmImport
          def self.imgadm_import(machine)
            ui = machine.ui
            sudo = machine.config.smartos.suexec_cmd
            image = machine.config.zone.image

            if image
              installed = machine.communicate.test("#{sudo} imgadm get #{image}")

              ui.info "Checking for zone image #{image}: #{installed ? 'installed' : 'not installed'}"
              if !installed
                ui.info "  Importing..."
                machine.communicate.execute("#{sudo} imgadm import #{image}")
              end
            else
              ui.info "No zone image set, skipping import"
            end
          end
        end
      end
    end
  end
end
