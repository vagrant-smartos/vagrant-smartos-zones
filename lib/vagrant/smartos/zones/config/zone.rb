require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      module Config
        class Zone < Vagrant.plugin('2', :config)
          attr_accessor :brand, :disk_size, :image, :kernel_version, :memory, :name
          attr_reader :synced_folders

          def initialize
            @brand = UNSET_VALUE
            @disk_size = UNSET_VALUE
            @image = UNSET_VALUE
            @kernel_version = UNSET_VALUE
            @memory = UNSET_VALUE
            @name = UNSET_VALUE
            @synced_folders = []
          end

          def synced_folder(*args)
            @synced_folders << args
          end

          def finalize!
            @brand = 'joyent' if @brand == UNSET_VALUE
            @kernel_version = '3.16' if @kernel_version == UNSET_VALUE
          end
        end
      end
    end
  end
end
