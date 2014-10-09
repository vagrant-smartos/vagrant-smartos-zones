module Vagrant
  module Smartos
    module Zones
      module Cap
        module ZoneGate
          class Enable
            def self.zone_gate_enable(machine)
              sudo = machine.config.smartos.suexec_cmd
              machine.ui.info "Enabling ZoneGate"

              machine.communicate.gz_execute("#{sudo} svcadm enable -s zonegate")
            end
          end
        end
      end
    end
  end
end
