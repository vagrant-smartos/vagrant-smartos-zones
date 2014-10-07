require 'vagrant'
require 'vagrant/smartos/zones/util/global_zone/ssh_info'
require 'vagrant/util/ssh'

module Vagrant
  module Smartos
    module Zones
      module Command
        class GlobalZone < Vagrant.plugin("2", :command)
          def self.synopsis
            "View and interact with the SmartOS global zone"
          end

          def execute
            options = {}

            opts = OptionParser.new do |o|
              o.banner = "Usage: vagrant global-zone [command]"
              o.separator ""
              o.separator "Commands:"
              o.separator "  ssh        ssh into the global zone"
              o.separator ""
              o.separator "Options:"
              o.separator ""
            end

            argv = parse_options(opts)
            return if !argv

            case argv.shift
            when "ssh"
              ssh
            else
              @env.ui.warn opts.to_s, prefix: false
              exit 1
            end
          end

          def ssh
            with_target_vms('default', single_target: true) do |machine|
              ssh_info = Util::GlobalZone::SSHInfo.new(machine.provider, machine.config, machine.env).to_hash
              Vagrant::Util::SSH.exec(ssh_info)
            end
          end
        end
      end
    end
  end
end
