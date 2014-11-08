require 'vagrant/smartos/zones/util/platform_images'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module PlatformImage
          class Latest
            def self.platform_image_latest(env)
              platform_image = Zones::Util::PlatformImages.new(env).show_latest
              env.ui.info 'Unable to find platform image' unless platform_image
              env.ui.info platform_image
            end
          end
        end
      end
    end
  end
end
