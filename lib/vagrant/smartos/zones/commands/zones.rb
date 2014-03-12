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
              o.separator "  show [name]      show info on zone"
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
            end
          end

          def list
            zones = []

            with_target_vms("default") do |machine|
              sudo = machine.config.smartos.suexec_cmd

              machine.communicate.execute("#{sudo} vmadm lookup -j") do |type, output|
                zone_data = JSON.parse(output)
                zone_data.each do |zone|
                  zones << [zone['alias'].to_s.ljust(25),
                            zone['zone_state'].to_s.ljust(10),
                            zone['zonename']].join(' ')
                end
              end
            end

            @env.ui.info(I18n.t("vagrant.smartos.zones.commands.zones.list",
                                 :zones => zones.join("\n")),
                                 :prefix => false)
          end

          def show(name)
            zone = {}
            with_target_vms("default") do |machine|
              sudo = machine.config.smartos.suexec_cmd
              machine.communicate.execute("#{sudo} vmadm lookup -j -o uuid,alias,state,image_uuid,brand alias=#{machine.config.zone.name}") do |type, output|
                zone = JSON.parse(output).first
              end
            end

            @env.ui.info(I18n.t("vagrant.smartos.zones.commands.zones.show",
                                 :name => zone['alias'].to_s,
                                 :state => zone['state'].to_s,
                                 :uuid => zone['uuid'].to_s,
                                 :brand => zone['brand'].to_s,
                                 :image => zone['image_uuid'].to_s),
                                 :prefix => false)
          end
        end
      end
    end
  end
end
