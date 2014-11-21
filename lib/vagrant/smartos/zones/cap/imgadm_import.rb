require 'vagrant/smartos/zones/cap/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        class ImgadmImport < Base
          cap_method :imgadm_import

          def execute
            return ui.info 'No zone image set, skipping import' unless image

            installed = machine.communicate.gz_test("#{sudo} imgadm get #{image}")

            ui.info "Checking for zone image #{image}: #{installed ? 'installed' : 'not installed'}"
            return if installed

            ui.info '  Importing...'
            machine.communicate.gz_execute("#{sudo} imgadm sources -a https://updates.joyent.com")
            machine.communicate.gz_execute("#{sudo} imgadm import #{image}")
          end

          def image
            machine.config.zone.image
          end
        end
      end
    end
  end
end
