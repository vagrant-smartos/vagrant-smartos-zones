require 'vagrant'
require 'vagrant/smartos/zones/models/zone'
require 'vagrant/smartos/zones/util/snapshots'
require 'vagrant/smartos/zones/util/zone_info'
require_relative 'multi_command'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Zones < Vagrant.plugin('2', :command)
          include MultiCommand

          COMMANDS = %w(create destroy list show snapshot start stop).freeze

          OPTION_PARSER = OptionParser.new do |o|
            o.banner = 'Usage: vagrant zones [command] [name]'
            o.separator ''
            o.separator 'Commands:'
            o.separator '  list                                 show status of zones'
            o.separator '  create [name]                        create or update zone with alias [name]'
            o.separator '  destroy [name]                       delete zone with alias [name]'
            o.separator '  show [name]                          show info on zone with alias [name]'
            o.separator '  snapshot [action] [name] [snapshot]  snapshot the ZFS filesystem for [name]'
            o.separator '                                       actions: list, create, delete, rollback'
            o.separator '  start [name]                         start zone with alias [name]'
            o.separator '  stop [name]                          stop zone with alias [name]'
            o.separator ''
            o.separator 'Options:'
            o.separator ''
          end

          def self.synopsis
            'View and interact with SmartOS zones'
          end

          def execute
            process_subcommand
          end

          def create(name)
            zones.create(name).tap do |zone|
              return unless zone
              @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.create',
                                  name: zone.name,
                                  state: zone.state,
                                  uuid: zone.uuid,
                                  brand: zone.brand,
                                  image: zone.image),
                           prefix: false)
            end
          end

          def destroy(name)
            @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.destroy', name: name))

            zones.destroy(name).tap do |zone|
              @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.destroyed',
                                  name: zone.name,
                                  state: zone.state,
                                  uuid: zone.uuid,
                                  brand: zone.brand,
                                  image: zone.image))
            end
          end

          def list(*_args)
            with_target_vms('default') do |machine|
              zones = Models::Zone.all(machine).map do |zone|
                [zone.name.to_s.ljust(25), zone.state.to_s.ljust(10), zone.uuid].join(' ')
              end
              @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.list',
                                  zones: zones.join("\n")), prefix: false)
            end
          end

          def show(name)
            zones.show(name).tap do |zone|
              @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.show',
                                  name: zone.name,
                                  state: zone.state,
                                  uuid: zone.uuid,
                                  brand: zone.brand,
                                  image: zone.image),
                           prefix: false)
            end
          end

          def snapshot(action = nil, name = nil, snapshot = nil)
            fail_options! unless action && name
            with_target_vms('default') do |machine|
              Util::Snapshots.new(machine, name).run(action, snapshot)
            end
          end

          def start(name)
            zones.start(name).tap do |zone|
              @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.start',
                                  name: zone.name,
                                  state: zone.state,
                                  uuid: zone.uuid,
                                  brand: zone.brand,
                                  image: zone.image))
            end
          end

          def stop(name)
            zones.stop(name).tap do |zone|
              @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.stop',
                                  name: zone.name,
                                  state: zone.state,
                                  uuid: zone.uuid,
                                  brand: zone.brand,
                                  image: zone.image))
            end
          end

          private

          def zones
            zones = nil
            with_target_vms('default') { |machine| zones = Util::ZoneInfo.new(machine) }
            zones
          end

          def ui
            @env.ui
          end
        end
      end
    end
  end
end
