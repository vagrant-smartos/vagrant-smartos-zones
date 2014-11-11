require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      module Config
        class Zone < Vagrant.plugin('2', :config)
          attr_accessor :brand, :kernel_version, :disk_size, :image, :memory, :name
          attr_reader :synced_folders

          def initialize
            @brand = UNSET_VALUE
            @kernel_version = UNSET_VALUE
            @disk_size = UNSET_VALUE
            @image = UNSET_VALUE
            @memory = UNSET_VALUE
            @name = UNSET_VALUE
            @synced_folders = []
          end

          def synced_folder(*args)
            @synced_folders << args
          end
        end
      end
    end
  end
end
