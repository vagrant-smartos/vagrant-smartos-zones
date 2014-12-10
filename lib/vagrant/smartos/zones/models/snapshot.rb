require 'vagrant/smartos/zones/errors'
require 'vagrant/smartos/zones/util/global_zone/helper'

module Vagrant
  module Smartos
    module Zones
      module Models
        class Snapshot
          include Util::GlobalZone::Helper

          attr_accessor :machine, :zone, :name, :created_at, :space_used

          def self.around(zone, &block)
            snapshot_name = "before_#{Time.now.to_i}"
            snapshot = create(snapshot_name, zone)
            if block.arity.eql?(1)
              block.call snapshot
            else
              block.call
            end
            snapshot.rollback
            snapshot.destroy
          end

          def self.all(zone)
            snapshots = []
            cmd = "pfexec zfs list -t snapshot -H -r -o name,creation,used zones/#{zone.uuid}"
            with_gz(zone.machine, cmd) do |output|
              break if output.include?('no datasets available')
              snapshots += output.split("\n").map { |l| from_line(l, zone) }
            end
            snapshots
          end

          def self.create(name, zone)
            cmd = "pfexec zfs snapshot zones/#{zone.uuid}@#{name}"
            with_gz(zone.machine, cmd)
            find(name, zone)
          end

          def self.find(name, zone)
            all(zone).find { |snapshot| snapshot.name == name } || raise(SnapshotNotFound)
          end

          def self.from_line(l, zone)
            name, created_at, used = l.split("\t")
            new.tap do |s|
              s.machine = zone.machine
              s.zone = zone
              s.name = name.split('@').last
              s.created_at = created_at
              s.space_used = used
            end
          end

          def path
            "zones/#{zone.uuid}@#{name}"
          end

          def destroy
            with_gz("pfexec zfs destroy #{path}")
          end

          def rollback
            with_gz("pfexec zfs rollback -r #{path}")
          end
        end
      end
    end
  end
end
