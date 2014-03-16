require 'vagrant'
require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Zones < Vagrant.plugin("2", :command)
          def self.synopsis
            "View and interact with SmartOS zones"
          end

          def execute
            options = {}

            opts = OptionParser.new do |o|
              o.banner = "Usage: vagrant zones [command] [name]"
              o.separator ""
              o.separator "Commands:"
              o.separator "  list             show status of zones"
              o.separator "  show [name]      show info on zone with alias [name]"
              o.separator "  start [name]     start zone with alais [name]"
              o.separator "  stop [name]      stop zone with alais [name]"
              o.separator ""
              o.separator "Options:"
              o.separator ""
            end

            argv = parse_options(opts)
            return if !argv

            case argv.shift
            when "list"
              list
            when "show"
              show *argv
            when "start"
              start *argv
            when "stop"
              stop *argv
            else
              @env.ui.warn opts.to_s, prefix: false
              exit 1
            end
          end

          def list
            zones = []

            with_target_vms("default") do |machine|
              zones.concat(Util::ZoneInfo.new(machine).list)
            end

            @env.ui.info(I18n.t("vagrant.smartos.zones.commands.zones.list",
                                 zones: zones.join("\n")),
                                 prefix: false)
          end

          def show(name)
            zone = {}
            with_target_vms("default") do |machine|
              zone.merge!(Util::ZoneInfo.new(machine).show(name))
            end

            @env.ui.info(I18n.t("vagrant.smartos.zones.commands.zones.show",
                                 name: zone['alias'].to_s,
                                 state: zone['state'].to_s,
                                 uuid: zone['uuid'].to_s,
                                 brand: zone['brand'].to_s,
                                 image: zone['image_uuid'].to_s),
                                 prefix: false)
          end

          def start(name)
            zone = {}
            with_target_vms("default") do |machine|
              zone.merge!(Util::ZoneInfo.new(machine).start(name))
            end

            @env.ui.info(I18n.t("vagrant.smartos.zones.commands.zones.start",
                                 name: zone['alias'].to_s,
                                 state: zone['state'].to_s,
                                 uuid: zone['uuid'].to_s,
                                 brand: zone['brand'].to_s,
                                 image: zone['image_uuid'].to_s))
          end

          def stop(name)
            zone = {}
            with_target_vms("default") do |machine|
              zone.merge!(Util::ZoneInfo.new(machine).stop(name))
            end

            @env.ui.info(I18n.t("vagrant.smartos.zones.commands.zones.stop",
                                 name: zone['alias'].to_s,
                                 state: zone['state'].to_s,
                                 uuid: zone['uuid'].to_s,
                                 brand: zone['brand'].to_s,
                                 image: zone['image_uuid'].to_s))
          end
        end
      end
    end
  end
end
