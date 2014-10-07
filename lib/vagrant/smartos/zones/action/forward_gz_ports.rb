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

          # This is probably dangerous. This runs *after* Vagrant
          # checks for port collisions.
          #   * this has to run before the guest is running
          #   * we can't know if it's smartos until the guest is running
          #   * we can only guess, because a zone is configured via this plugin
          #
          # Maybe we'll need to set up more complicated branching logic throughout
          # the plugin. If there is a local zone configured, then we will have a
          # gz_ssh port forward. Then when talking to the guest, we'll have to 
          # choose between gz_ssh and ssh depending on certain conditions.
          #
          # This should definitely run through the port collision detection, and
          # then communication should be dynamic based on the runtime info of this
          # port forward.
          def call(env)

            if zone_configured?
              machine.ui.info "Configuring a port forward to talk to the Global Zone"

              env[:forwarded_ports] ||= compile_forwarded_ports(env[:machine].config)

              network = machine.config.vm.networks.first
              options = scoped_hash_override(network[1], :virtualbox)

              gz_forward = VagrantPlugins::ProviderVirtualBox::Model::ForwardedPort.new(
                'gz_ssh',
                machine.config.global_zone.forwarded_ssh_port,
                machine.config.global_zone.ssh_port,
                options
              )
              env[:forwarded_ports] << gz_forward
            end

            app.call(env)
          end
        end
      end
    end
  end
end
