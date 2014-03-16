module Vagrant
  module Smartos
    module Zones
      module Cap
        class ZoneCreate
          def self.zone_create(machine)
            ui = machine.ui
            name = machine.config.zone.name

            if zone_exists?(machine)
              ui.info "Zone #{name} exists"
              ui.info "Updating..."
              update_zone(machine)
            else
              ui.info "Creating zone #{name} with image #{machine.config.zone.image}"
              create_zone(machine)
              ui.info "Zone created with uuid #{zone_uuid(machine)}"
            end
          end

          def self.create_zone(machine)
            sudo = machine.config.smartos.suexec_cmd
            machine.communicate.execute("echo '#{zone_json(machine)}' | #{sudo} vmadm create")
          end

          def self.update_zone(machine)
            sudo = machine.config.smartos.suexec_cmd
            machine.communicate.execute("echo '#{zone_json(machine)}' | #{sudo} vmadm update #{zone_uuid(machine)}")
          end

          def self.zone_json(machine)
            {
              "brand" => machine.config.zone.brand,
              "alias" => machine.config.zone.name,
              "dataset_uuid" => machine.config.zone.image,
              "quota" => machine.config.zone.disk_size || 1,
              "max_physical_memory" => machine.config.zone.memory || 64,
              "nics" => [
                { "nic_tag" => "admin", "ip" => "dhcp"}
              ]
            }.to_json
          end

          def self.zone_exists?(machine)
            name = machine.config.zone.name
            sudo = machine.config.smartos.suexec_cmd

            machine.communicate.test("#{sudo} vmadm list -H | awk '{print $5}' | grep #{name}")
          end

          def self.zone_uuid(machine)
            sudo = machine.config.smartos.suexec_cmd
            uuid = ''
            machine.communicate.execute("#{sudo} vmadm lookup alias=#{machine.config.zone.name}") do |type, output|
              uuid << output
            end
            uuid
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
