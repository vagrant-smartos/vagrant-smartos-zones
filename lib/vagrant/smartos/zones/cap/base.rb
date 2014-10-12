module Vagrant
  module Smartos
    module Zones
      module Cap
        class Base
          attr_reader :machine

          def self.cap_method(method_name)
            self.class.send :define_method, method_name do |machine|
              new(machine).execute
            end
          end

          def initialize(machine)
            @machine = machine
          end

          def ui
            machine.ui
          end

          def sudo
            machine.config.smartos.suexec_cmd
          end
        end
      end
    end
  end
end
