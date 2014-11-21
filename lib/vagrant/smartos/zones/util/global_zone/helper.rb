module Vagrant
  module Smartos
    module Zones
      module Util
        module GlobalZone
          module Helper
            def sudo
              machine.config.smartos.suexec_cmd
            end

            def with_gz(command, options = {})
              machine.communicate.gz_execute(command, options) do |_type, output|
                yield output if block_given?
              end
            end

            def zlogin(zone, cmd, options = {})
              with_gz("#{sudo} zlogin #{zone.uuid} #{cmd}", options) do |output|
                yield output if block_given?
              end
            end

            def zlogin_test(zone, cmd)
              command = "#{sudo} zlogin #{zone.uuid} #{cmd}"
              machine.communicate.gz_test(command)
            end
          end
        end
      end
    end
  end
end
