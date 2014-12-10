require 'vagrant'
require 'vagrant/smartos/zones/util/global_zone/ssh_info'
require 'vagrant/smartos/zones/models/zone'
require 'vagrant/util/ssh'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Zlogin < Vagrant.plugin('2', :command)
          OPTION_PARSER = OptionParser.new do |o|
            o.banner = 'Usage: vagrant zlogin [name]'
          end

          def self.synopsis
            'Log into a SmartOS local zone'
          end

          def execute
            argv = parse_options(OPTION_PARSER)
            return unless argv

            zone_alias = argv.shift

            with_target_vms('default', single_target: true) do |machine|
              ssh_info = Util::GlobalZone::SSHInfo.new(machine.provider, machine.config, machine.env).to_hash
              zone = Models::Zone.find(machine, zone_alias)
              Vagrant::Util::SSH.exec(ssh_info, extra_args: ['-t', "pfexec zlogin -l vagrant #{zone.uuid}"])
            end
          end
        end
      end
    end
  end
end
