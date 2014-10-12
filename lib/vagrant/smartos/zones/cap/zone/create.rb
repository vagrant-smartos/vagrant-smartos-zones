require 'vagrant/smartos/zones/cap/zone/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Zone
          class Create < Base
            cap_method :zone__create

            def execute
              return warn_zone_config unless zone_valid?
              return update_zone if zone_exists?
              create_zone
            end

            def create_zone
              ui.info "Creating zone #{machine.config.zone.name} with image #{machine.config.zone.image}"
              machine.communicate.gz_execute("echo '#{zone_json}' | #{sudo} vmadm create")
              machine.guest.capability(:create_zone_users)
              ui.info "Zone created with uuid #{zone_uuid}"
            end

            def update_zone
              ui.info "Zone #{machine.config.zone.name} exists"
              ui.info 'Updating...'
              machine.communicate.gz_execute("echo '#{zone_json}' | #{sudo} vmadm update #{zone_uuid}")
            end

            def warn_zone_config
              ui.info 'No zone configured, skipping'
              ui.info '   add the following to your Vagrantfile to configure a local zone:'
              ui.info "      config.zone.name      = 'my-zone'"
              ui.info "      config.zone.image     = 'uuid'"
              ui.info "      config.zone.brand     = 'joyent'"
              ui.info '      config.zone.memory    = 2048'
              ui.info '      config.zone.disk_size = 5'
            end

            def zone_json
              {
                'brand' => machine.config.zone.brand,
                'alias' => machine.config.zone.name,
                'dataset_uuid' => machine.config.zone.image,
                'quota' => machine.config.zone.disk_size || 1,
                'max_physical_memory' => machine.config.zone.memory || 64,
                'fs_allowed' => 'vboxfs',
                'resolvers' => [
                  '8.8.8.8',
                  '8.8.4.4'
                ],
                'nics' => [
                  {
                    'nic_tag' => 'stub0',
                    'ip' => '10.0.0.2',
                    'netmask' => '255.255.255.0',
                    'gateway' => '10.0.0.1',
                    'allow_ip_spoofing' => true
                  }
                ]
              }.to_json
            end

            def zone_uuid
              uuid = ''
              command = "#{sudo} vmadm lookup alias=#{machine.config.zone.name}"
              machine.communicate.gz_execute(command) do |_type, output|
                uuid << output
              end
              uuid
            end
          end
        end
      end
    end
  end
end
