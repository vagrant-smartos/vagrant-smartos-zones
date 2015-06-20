require 'vagrant/smartos/zones/cap/base'
require 'vagrant/smartos/zones/models/dataset'
require 'vagrant/smartos/zones/util/datasets/manifest'
require 'vagrant/smartos/zones/util/zone_image'

module Vagrant
  module Smartos
    module Zones
      module Cap
        class ImgadmImport < Base
          cap_method :imgadm_import

          def execute
            return ui.info 'No zone image set, skipping import' unless image

            if zone_image.install_override?
              install
            else
              import
            end
          end

          private

          def image
            machine.config.zone.image
          end

          def import
            ui.info "Zone image #{image}: installed" && return if installed?(image)
            ui.info "  Importing zone image #{image}..."
            machine.communicate.gz_execute("#{sudo} imgadm sources -a https://updates.joyent.com")
            machine.communicate.gz_execute("#{sudo} imgadm import #{image}")
          end

          def installed?(uuid)
            machine.communicate.gz_test("#{sudo} imgadm get #{uuid}")
          end

          def install
            uuid = zone_image.override_uuid
            ui.info "Swapping out image #{uuid} for #{image}"
            ui.info "Zone image #{uuid}: installed" && return if installed?(uuid)
            dataset = Models::Dataset.install(zone_image.override, machine)
            machine.communicate.gz_upload(manifest.local_filename, manifest.remote_filename)
            ui.info "  Installing zone image #{uuid}..."
            machine.communicate.gz_execute("#{sudo} imgadm install -m #{manifest.remote_filename} -f #{dataset.remote_filename}")
          end

          def manifest
            @manifest ||= Util::Datasets::Manifest.new(zone_image.override, machine.env).load!
          end

          def zone_image
            @zone_image ||= Util::ZoneImage.new(machine)
          end
        end
      end
    end
  end
end
