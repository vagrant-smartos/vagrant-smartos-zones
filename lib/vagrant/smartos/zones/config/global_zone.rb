require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      module Config
        class GlobalZone < Vagrant.plugin("2", :config)
          attr_accessor :platform_image

          def initialize
            platform_image = UNSET_VALUE
          end

          def finalize!
            platform_image = 'latest' if platform_image== UNSET_VALUE
          end
        end
      end
    end
  end
end
