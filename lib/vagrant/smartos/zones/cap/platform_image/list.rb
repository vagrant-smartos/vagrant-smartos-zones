require 'vagrant/smartos/zones/util/platform_images'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module PlatformImage
          class List
            def self.platform_image_list(env)
              Zones::Util::PlatformImages.new(env).list
            end
          end
        end
      end
    end
  end
end
