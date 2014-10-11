require 'vagrant'
require 'vagrant/smartos/zones/util/global_zone/ssh_info'
require 'vagrant/smartos/zones/util/zone_info'
require 'vagrant/util/ssh'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Zlogin < Vagrant.plugin('2', :command)
          def self.synopsis
            'Log into a SmartOS local zone'
          end

          def execute
            options = {}

            opts = OptionParser.new do |o|
              o.banner = 'Usage: vagrant zlogin [name]'
            end

            argv = parse_options(opts)
            return unless argv

            zone_alias = argv.shift

            with_target_vms('default', single_target: true) do |machine|
              ssh_info = Util::GlobalZone::SSHInfo.new(machine.provider, machine.config, machine.env).to_hash
              zone = Util::ZoneInfo.new(machine).show(zone_alias)
              Vagrant::Util::SSH.exec(ssh_info, extra_args: ['-t', "pfexec zlogin -l vagrant #{zone.uuid}"])
            end
          end
        end
      end
    end
  end
end
