require 'pry'
module Vagrant
  module Smartos
    module Zones
      module Cap
        class ZoneCreate
          def self.zone_create(machine)
            ui = machine.ui
            if zone_exists?(machine)
              ui.info "Zone exists"
            else
              ui.info "Creating zone #{machine.config.zone.name}"
              create_zone(machine)
            end
          end

          def self.create_zone(machine)
            sudo = machine.config.smartos.suexec_cmd

            json = {
              "brand" => machine.config.zone.brand,
              "alias" => machine.config.zone.name,
              "dataset_uuid" => machine.config.zone.image,
              "quota" => 1,
              "max_physical_memory" => 64,
              "nics" => [
                { "nic_tag" => "admin", "ip" => "dhcp"}
              ]
            }.to_json

            machine.communicate.execute("echo '#{json}' | #{sudo} vmadm create")
          end

          def self.zone_exists?(machine)
            name = machine.config.zone.name
            sudo = machine.config.smartos.suexec_cmd

            machine.communicate.test("#{sudo} vmadm list -H | awk '{print $5}' | grep #{name}")
          end

          def self.list_zones(machine)
            sudo = machine.config.smartos.suexec_cmd
            zones = ''

            machine.communicate.execute("#{sudo} vmadm list -H", {}) do |type, output|
              zones << output
            end

            zones.split("\n")
          end
        end
      end
    end
  end
end
