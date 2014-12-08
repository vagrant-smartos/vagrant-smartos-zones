module Vagrant
  module Smartos
    module Zones
      module Util
        module GlobalZone
          module Helper
            def self.included(klass)
              klass.send(:extend, ClassHelpers)
            end

            def sudo
              machine.config.smartos.suexec_cmd
            end

            def with_gz(command, options = {})
              machine.communicate.gz_execute(command, options) do |_type, output|
                yield output if block_given?
              end
            end
          end

          module ClassHelpers
            def with_gz(machine, command, options = {})
              machine.communicate.gz_execute(command, options) do |_type, output|
                yield output if block_given?
              end
            end
          end
        end
      end
    end
  end
end
