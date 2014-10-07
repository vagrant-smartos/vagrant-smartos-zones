require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      class Guest < Vagrant.plugin("2", :guest)
        TEST_COMMAND = "grep 'SmartOS [0-9]\\{8\\}T[0-9]\\{6\\}Z' /etc/release"

        def detect?(machine)
          @machine = machine
          ssh_test || gz_test
        end

        def ssh_test
          @machine.communicate.test(TEST_COMMAND)
        end

        def gz_test
          return false unless @machine.communicate.respond_to?(:gz_test)
          @machine.communicate.gz_test(TEST_COMMAND)
        end
      end
    end
  end
end
