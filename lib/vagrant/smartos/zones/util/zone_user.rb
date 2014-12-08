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
            zone.zlogin("useradd #{flags(group)} #{username}")
            grant_role(username, role)
            install_public_key(group)
          end

          private

          def flags(group)
            return "-m -s /bin/bash -g #{group}" if zone.lx_brand?
            "-m -s /bin/bash -g #{group} -G other"
          end

          def grant_role(username, role)
            if zone.lx_brand?
              return if zone.test(%('test -f /etc/sudoers.d/vagrant'))
              zone.zlogin(%('echo "#{username} ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vagrant'))
            else
              zone.zlogin("usermod -P\\'#{role}\\' #{username}") if role
              zone.zlogin('cp /opt/local/etc/sudoers.d/admin /opt/local/etc/sudoers.d/vagrant')
              zone.zlogin('sed -i -e \\\'s@admin@vagrant@\\\' /opt/local/etc/sudoers.d/vagrant')
            end
          end

          def install_public_key(group)
            zone.zlogin('mkdir -p /home/vagrant/.ssh')
            zone.zlogin('touch /home/vagrant/.ssh/authorized_keys')
            zone.zlogin(%('echo "#{PublicKey.new}" > /home/vagrant/.ssh/authorized_keys'))
            zone.zlogin("chown -R vagrant:#{group} /home/vagrant/.ssh")
            zone.zlogin('chmod 600 /home/vagrant/.ssh/authorized_keys')
          end
        end
      end
    end
  end
end
