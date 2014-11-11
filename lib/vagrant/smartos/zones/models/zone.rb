module Vagrant
  module Smartos
    module Zones
      module Models
        class Zone
          attr_accessor :name, :state, :uuid, :brand, :kernel_version, :image

          def self.from_hash(zone)
            new.tap do |z|
              z.name = zone['alias']
              z.uuid = zone['uuid']
              z.brand = zone['brand']
              z.kernel_version = zone['kernel_version']
              z.state = zone['state']
              z.image = zone['image_uuid']
            end
          end

          def running?
            state == 'running'
          end
        end
      end
    end
  end
end
