module Vagrant
  module Smartos
    module Zones
      module Util
        module GlobalZone
          module Helper
            def sudo
              machine.config.smartos.suexec_cmd
            end

            def with_gz(command)
              machine.communicate.gz_execute(command) do |_type, output|
                yield output if block_given?
              end
            end

            def zlogin(zone, cmd)
              with_gz("#{sudo} zlogin #{zone.uuid} #{cmd}")
            end
          end
        end
      end
    end
  end
end
