require 'vagrant/smartos/zones/cap/zone/base'
require 'vagrant/smartos/zones/util/zone_json'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Create < Base
            cap_method :zone__create

            def execute
              return warn_zone_config unless zone_valid?
              return update_zone if zone_exists?
              create_zone
            end

            def create_zone
              zone_info.create(machine.config.zone.name)
            end

            def update_zone
              ui.info "Zone #{machine.config.zone.name} exists"
              zone_info.update(machine.config.zone.name)
            end

            def warn_zone_config
              ui.info 'No zone configured, skipping'
              ui.info '   add the following to your Vagrantfile to configure a local zone:'
              ui.info "      config.zone.name            = 'my-zone'"
              ui.info "      config.zone.image           = 'uuid'"
              ui.info "      config.zone.brand           = 'joyent'"
              ui.info "      config.zone.kernel_version  = '3.16'"
              ui.info '      config.zone.memory          = 2048'
              ui.info '      config.zone.disk_size       = 5'
            end

            def zone_json
              Util::ZoneJson.new(machine).to_json
            end
          end
        end
      end
    end
  end
end
