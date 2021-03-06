require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      module Config
        class GlobalZone < Vagrant.plugin('2', :config)
          attr_accessor :platform_image, :platform_image_url, :ssh_port, :forwarded_ssh_port

          def initialize
            @platform_image = UNSET_VALUE
            @platform_image_url = UNSET_VALUE
            @ssh_port = UNSET_VALUE
            @forwarded_ssh_port = UNSET_VALUE
          end

          def finalize!
            @platform_image = 'latest' if @platform_image == UNSET_VALUE
            @platform_image_url = nil if @platform_image_url == UNSET_VALUE
            @ssh_port = 2222 if @ssh_port == UNSET_VALUE
            @forwarded_ssh_port = 22_022 if @forwarded_ssh_port == UNSET_VALUE
          end
        end
      end
    end
  end
end
