require 'vagrant/smartos/zones/models/snapshot'
require 'vagrant/smartos/zones/util/global_zone/helper'

module Vagrant
  module Smartos
    module Zones
      module Models
        class Dataset
          include Util::GlobalZone::Helper

          def self.create(name, zone)
            Models::Snapshot.around(zone) do
              zone.zlogin('\'find /var/log -type f -exec truncate --size 0 {} \;\'')
              zone.zlogin('sm-prepare-image -y')
              zone.stop
              Models::Snapshot.around(zone) do |snapshot|
                cmd = 'pfexec /usr/bin/bash -l -c "/usr/sbin/zfs send %s | /usr/bin/bzip2 > /zones/%s.zfs.bz2"'
                with_gz(zone.machine, cmd % [snapshot.path, name])
              end
            end
            zone.start
          end
        end
      end
    end
  end
end
