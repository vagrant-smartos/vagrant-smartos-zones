require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Cap
        class CreateZoneUsers
          def self.create_zone_users(machine)
            ui = machine.ui
            zone = Util::ZoneInfo.new(machine).show(machine.config.zone.name)
            ui.info "Creating users in zone #{zone.name} #{zone.uuid}"

            machine.communicate.execute("pfexec zlogin #{zone.uuid} useradd -m -s /bin/bash vagrant")
            machine.communicate.execute("pfexec zlogin #{zone.uuid} usermod -P\\'Primary Administrator\\' vagrant")
          end
        end
      end
    end
  end
end

