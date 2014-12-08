require 'vagrant/smartos/zones/cap/base'
require 'vagrant/smartos/zones/models/zone'
require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Base < Vagrant::Smartos::Zones::Cap::Base
            def zone_exists?
              name = machine.config.zone.name
              machine.communicate.gz_test("#{sudo} vmadm list -H | awk '{print $5}' | grep #{name}")
            end

            def zone_valid?
              machine.config.zone && machine.config.zone.image && machine.config.zone.name
            end

            def zone_info
              @zone_info ||= Util::ZoneInfo.new(machine)
            end

            def zone
              @zone ||= Models::Zone.find(machine, machine.config.zone.name)
            end
          end
        end
      end
    end
  end
end
