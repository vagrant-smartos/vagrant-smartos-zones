require 'vagrant/smartos/zones/util/platform_images'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module PlatformImage
          class Latest
            def self.platform_image_latest(env)
              Zones::Util::PlatformImages.new(env).show_latest
            end
          end
        end
      end
    end
  end
end
