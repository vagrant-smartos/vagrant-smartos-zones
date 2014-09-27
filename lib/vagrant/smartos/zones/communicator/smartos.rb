module Vagrant
  module Smartos
    module Zones
      module Communicator
        class Smartos < Vagrant.plugin("2").manager.communicators[:ssh]
          def initialize(machine)
            @machine = machine
            @original_ssh_port = 2222
            machine.ui.info "hey there. I'm a smartos communicator"
            super
          end
          # 
          # def execute(command, opts=nil, &block)
          #   @machine.ui.info 'ohai execute'
          #   wrap_method do
          #     @machine.ui.info 'wrapped'
          #     @machine.ui.info @machine.ssh_info.inspect
          #     super(command, opts, &block)
          #   end
          # end
          #
          # def sudo(command, opts=nil, &block)
          #   @machine.ui.info 'ohai sudo'
          #   wrap_method do
          #     super(command, opts, &block)
          #   end
          # end
          #
          # def upload(from, to)
          #   @machine.ui.info 'ohai upload'
          #   wrap_method do
          #     super(from, to)
          #   end
          # end
          #
          # def download(from, to=nil)
          #   @machine.ui.info 'ohai download'
          #   wrap_method do
          #     super(from, to)
          #   end
          # end
          #
          # private
          #
          # def wrap_method
          #   @machine.ui.info 'oh hey I got yr ssh port'
          #   @machine.ui.info @machine.config.ssh.shell
          #   @original_ssh_port = @machine.ssh_info[:port]
          #   @machine.ssh_info[:port] = 2222
          #   yield
          #   @machine.ssh_info[:port] = @original_ssh_port
          # end
        end
      end
    end
  end
end
