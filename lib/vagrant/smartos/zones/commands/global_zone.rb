require 'vagrant'
require 'vagrant/smartos/zones/util/global_zone/ssh_info'
require 'vagrant/util/ssh'
require_relative 'multi_command'

module Vagrant
  module Smartos
    module Zones
      module Command
        class GlobalZone < Vagrant.plugin('2', :command)
          include MultiCommand

          COMMANDS = %w(ssh)

          OPTION_PARSER = OptionParser.new do |o|
            o.banner = 'Usage: vagrant global-zone [command]'
            o.separator ''
            o.separator 'Commands:'
            o.separator '  ssh        ssh into the global zone'
            o.separator ''
            o.separator 'Options:'
            o.separator ''
          end

          def self.synopsis
            'View and interact with the SmartOS global zone'
          end

          def ssh(*_args)
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
