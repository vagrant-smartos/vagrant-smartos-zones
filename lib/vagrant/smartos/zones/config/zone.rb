require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      module Config
        class Zone < Vagrant.plugin("2", :config)
          attr_accessor :brand, :disk_size, :image, :memory, :name
        end
      end
    end
  end
end
