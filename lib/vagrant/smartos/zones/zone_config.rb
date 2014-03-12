module Vagrant
  module Smartos
    module Zones
      class ZoneConfig < Vagrant.plugin("2", :config)
        attr_accessor :brand, :disk_size, :image, :memory, :name

        def install(&block)
        end
      end
    end
  end
end
