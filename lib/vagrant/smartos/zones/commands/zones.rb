require 'vagrant'
require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Zones < Vagrant.plugin('2', :command)
          COMMANDS = %w(create destroy list show start stop).freeze

          OPTION_PARSER = OptionParser.new do |o|
            o.banner = 'Usage: vagrant zones [command] [name]'
            o.separator ''
            o.separator 'Commands:'
            o.separator '  list             show status of zones'
            o.separator '  create [name]    create or update zone with alais [name]'
            o.separator '  destroy [name]   delete zone with alais [name]'
            o.separator '  show [name]      show info on zone with alias [name]'
            o.separator '  start [name]     start zone with alais [name]'
            o.separator '  stop [name]      stop zone with alais [name]'
            o.separator ''
            o.separator 'Options:'
            o.separator ''
          end

          def self.synopsis
            'View and interact with SmartOS zones'
          end

          def execute
            argv = parse_options(OPTION_PARSER)
            return unless argv

            command = argv.shift
            command_method = COMMANDS.find { |c| c == command }

            unless command_method
              @env.ui.warn OPTION_PARSER.to_s, prefix: false
              exit 1
            end

            send command_method, argv.first
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
            zones.list.tap do |zone_list|
              @env.ui.info(I18n.t('vagrant.smartos.zones.commands.zones.list',
                                  zones: zone_list.join("\n")),
                           prefix: false)
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
        end
      end
    end
  end
end
