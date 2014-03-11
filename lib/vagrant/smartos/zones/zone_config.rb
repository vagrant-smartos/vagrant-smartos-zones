module Vagrant
  module Smartos
    module Zones
      class ZoneConfig < Vagrant.plugin("2", :config)
        attr_accessor :alias, :brand, :image

        def install(&block)
        end
      end
    end
  end
end
