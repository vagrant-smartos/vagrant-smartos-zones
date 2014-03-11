module Vagrant
  module Smartos
    module Zones
      class ZoneConfig < Vagrant.plugin("2", :config)
        attr_accessor :brand, :image, :name

        def install(&block)
        end
      end
    end
  end
end
