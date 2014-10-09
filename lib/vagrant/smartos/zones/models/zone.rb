module Vagrant
  module Smartos
    module Zones
      module Models
        class Zone
          attr_accessor :name, :state, :uuid, :brand, :image

          def running?
            state == 'running'
          end
        end
      end
    end
  end
end
