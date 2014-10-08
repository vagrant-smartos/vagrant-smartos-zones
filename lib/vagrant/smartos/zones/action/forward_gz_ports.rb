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

            if zone_configured?
              machine.ui.info "Configuring a port forward to talk to the Global Zone"

              network = machine.config.vm.networks.first
              options = scoped_hash_override(network[1], :virtualbox)

              machine.config.vm.network :forwarded_port, options.merge({
                id: 'gz_ssh',
                guest: machine.config.global_zone.ssh_port,
                host: machine.config.global_zone.forwarded_ssh_port,
                auto_correct: true
              })
            end

            app.call(env)
          end
        end
      end
    end
  end
end
