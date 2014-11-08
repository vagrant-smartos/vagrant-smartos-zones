require 'vagrant/smartos/zones/models/zone_user'
require 'vagrant/smartos/zones/util/global_zone/helper'
require 'vagrant/smartos/zones/util/public_key'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneUser
          include GlobalZone::Helper

          attr_reader :machine, :zone

          def initialize(machine, zone)
            @machine = machine
            @zone = zone
          end

          def find(username)
            Models::ZoneUser.new.tap do |u|
              u.name = username
              machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} id -u #{username}") do |_type, output|
                u.uid = output.chomp
              end
            end
          end

          def create(username, group, role = nil)
            zlogin(zone, "useradd -m -s /bin/bash -G #{group} #{username}")
            zlogin(zone, "usermod -P\\'#{role}\\' #{username}") if role
            install_public_key
          end

          private

          def install_public_key
            zlogin(zone, 'mkdir -p /home/vagrant/.ssh')
            zlogin(zone, 'touch /home/vagrant/.ssh/authorized_keys')
            zlogin(zone, %('echo "#{PublicKey.new}" > /home/vagrant/.ssh/authorized_keys'))
            zlogin(zone, 'chown -R vagrant:other /home/vagrant/.ssh')
            zlogin(zone, 'chmod 600 /home/vagrant/.ssh/authorized_keys')
          end
        end
      end
    end
  end
end
