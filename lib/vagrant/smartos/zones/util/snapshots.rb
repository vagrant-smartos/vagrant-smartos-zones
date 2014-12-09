require 'vagrant/smartos/zones/models/snapshot'

module Vagrant
  module Smartos
    module Zones
      module Util
        class Snapshots
          include GlobalZone::Helper

          attr_reader :machine, :zonename

          def initialize(machine, zonename)
            @machine = machine
            @zonename = zonename
          end

          def run(action, snapshot = nil)
            send action, snapshot
          end

          def list(_snapshot)
            Models::Snapshot.all(zone).tap do |snapshots|
              sns = snapshots.map do |snapshot|
                [snapshot.name.ljust(12), snapshot.created_at.to_s.ljust(21),
                 snapshot.space_used.to_s.rjust(6), snapshot.zone.name].join(' ')
              end
              machine.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.snapshot.list',
                                     snapshots: sns.join("\n")), prefix: false)
            end
          end

          def create(name)
            machine.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.snapshot.create',
                                   name: name), prefix: false)
            Models::Snapshot.create(name, zone)
          end

          def destroy(name)
            Models::Snapshot.find(name, zone).tap do |snapshot|
              machine.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.snapshot.destroy',
                                     name: snapshot.name), prefix: false)
              snapshot.destroy
            end
          end

          def rollback(name)
            Models::Snapshot.find(name, zone).tap do |snapshot|
              machine.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.snapshot.rollback',
                                     zonename: zone.name, name: snapshot.name), prefix: false)
              snapshot.rollback
            end
          end

          private

          def zone
            @zone ||= Models::Zone.find(machine, zonename)
          end
        end
      end
    end
  end
end
