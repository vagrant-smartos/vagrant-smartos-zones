require 'vagrant/smartos/zones/util/platform_images'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module PlatformImage
          class Install
            def self.platform_image_install(env, image)
              Zones::Util::PlatformImages.new(env).install(image)
            end
          end
        end
      end
    end
  end
end
