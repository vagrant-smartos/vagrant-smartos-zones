module Vagrant
  module Smartos
    module Zones
      class Guest < Vagrant.plugin("2", :guest)
        def detect?(machine)
          machine.communicate.test("grep 'SmartOS [0-9]\\{8\\}T[0-9]\\{6\\}Z' /etc/release")
        end
      end
    end
  end
end
