require 'vagrant/smartos/zones/action/helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        class ForwardGZPorts
          include VagrantPlugins::ProviderVirtualBox::Util::CompileForwardedPorts
          include Helper

          def initialize(app, env)
            @app = app
            @env = env
          end

          # This middleware sets up a VirtualBox port forward to 2222 in the global zone.
          # ipnat in the global zone is configured to route this to 22 in the global zone,
          # even when all other ports are forwarded to a zone.
          def call(env)
            configure_gz_port_forward if zone_configured?

            app.call(env)
          end

          def configure_gz_port_forward
            machine.ui.info 'Configuring a port forward to talk to the Global Zone'
            machine.config.vm.network :forwarded_port, port_forward_options
          end

          def network
            machine.config.vm.networks.first
          end

          def port_forward_options
            scoped_hash_override(network[1], :virtualbox).merge(
              id: 'gz_ssh',
              guest: machine.config.global_zone.ssh_port,
              host: machine.config.global_zone.forwarded_ssh_port,
              auto_correct: true
            )
          end
        end
      end
    end
  end
end
