module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneJson
          attr_reader :machine

          def initialize(machine)
            @machine = machine
          end

          def to_json
            zone_info
              .merge(generics)
              .merge(resolvers)
              .merge(nics).to_json
          end

          def zone_info
            {
              'brand' => machine.config.zone.brand,
              'alias' => machine.config.zone.name,
              'dataset_uuid' => machine.config.zone.image,
              'quota' => machine.config.zone.disk_size || 1,
              'max_physical_memory' => machine.config.zone.memory || 64
            }
          end

          def generics
            {
              'fs_allowed' => 'vboxfs'
            }
          end

          def resolvers
            {
              'resolvers' => [
                '8.8.8.8',
                '8.8.4.4'
              ]
            }
          end

          def nics
            {
              'nics' => [nic_info('stub0', '10.0.0.2')]
            }
          end

          def nic_info(tag, ip)
            {
              'nic_tag' => tag,
              'ip' => ip,
              'netmask' => '255.255.255.0',
              'gateway' => '10.0.0.1',
              'allow_ip_spoofing' => true
            }
          end
        end
      end
    end
  end
end
