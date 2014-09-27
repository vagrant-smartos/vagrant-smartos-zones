require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      module Config
        class GlobalZone < Vagrant.plugin("2", :config)
          attr_accessor :platform_image, :ssh_port, :forwarded_ssh_port

          def initialize
            @platform_image = UNSET_VALUE
            @ssh_port = UNSET_VALUE
            @forwarded_ssh_port = UNSET_VALUE
          end

          def finalize!
            @ssh_port = 2222 if @ssh_port == UNSET_VALUE
            @forwarded_ssh_port = 22022 if @forwarded_ssh_port == UNSET_VALUE
          end
        end
      end
    end
  end
end
