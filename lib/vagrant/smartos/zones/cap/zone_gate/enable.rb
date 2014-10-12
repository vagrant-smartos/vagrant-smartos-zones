require 'vagrant/smartos/zones/cap/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module ZoneGate
          class Enable < Cap::Base
            cap_method :zone_gate_enable

            def execute
              ui.info 'Enabling ZoneGate'
              machine.communicate.gz_execute("#{sudo} svcadm enable -s zonegate")
            end
          end
        end
      end
    end
  end
end
