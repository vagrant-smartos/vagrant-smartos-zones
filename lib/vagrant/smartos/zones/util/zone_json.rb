require 'vagrant/smartos/zones/models/network'
require 'vagrant/smartos/zones/util/zone_image'

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
              .merge(kernel_version)
              .merge(resolvers)
              .merge(nics).to_json
          end

          def zone_info
            {
              'brand' => machine.config.zone.brand,
              'alias' => machine.config.zone.name,
              'dataset_uuid' => image,
              'quota' => machine.config.zone.disk_size || 1,
              'max_physical_memory' => machine.config.zone.memory || 64
            }
          end

          def generics
            {
              'fs_allowed' => 'vboxfs'
            }
          end

          def kernel_version
            return {} unless lx_brand?
            {
              'kernel_version' => machine.config.zone.kernel_version
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
              'nics' => [nic_info('stub0', network.zone_ip)]
            }
          end

          def nic_info(tag, ip)
            {
              'nic_tag' => tag,
              'ip' => ip,
              'netmask' => '255.255.255.0',
              'gateway' => network.gz_stub_ip,
              'allow_ip_spoofing' => true
            }
          end

          def image
            zone_image.install_override? ? zone_image.override_uuid : machine.config.zone.image
          end

          private

          def lx_brand?
            machine.config.zone.brand == 'lx'
          end

          def network
            @network ||= Models::Network.new(machine.env)
          end

          def zone_image
            @zone_image ||= Util::ZoneImage.new(machine)
          end
        end
      end
    end
  end
end
