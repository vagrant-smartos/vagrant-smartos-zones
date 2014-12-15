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
              Models::Zone.create_or_update(machine.config.zone.name, machine)
            end

            def warn_zone_config
              ui.info 'No zone configured, skipping'
              ui.info '   add the following to your Vagrantfile to configure a local zone:'
              ui.info "      config.zone.name      = 'my-zone'"
              ui.info "      config.zone.image     = 'uuid'"
              ui.info "      config.zone.brand     = 'joyent'"
              ui.info '      config.zone.memory    = 2048'
              ui.info '      config.zone.disk_size = 5'
            end
          end
        end
      end
    end
  end
end
