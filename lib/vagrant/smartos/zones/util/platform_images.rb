require 'vagrant/smartos/zones/util/checksum'
require 'vagrant/smartos/zones/util/downloader'

module Vagrant
  module Smartos
    module Zones
      module Util
        class PlatformImages
          attr_reader :env

          def initialize(env)
            @env = env
            setup_smartos_directories
          end

          def install(image)
            if ::File.exists?(platform_image_path(image)) && valid?(image)
              env.ui.info "Image #{image} already exists"
            else
              Downloader.get(platform_image_checksum_url(image), platform_image_checksum_path(image))
              Downloader.get(platform_image_url(image), platform_image_path(image))
            end
          end

          def list
            images = Dir[images_dir.join('*')].map do |f|
              File.basename(f, '.iso')
            end

            env.ui.info(images.join("\n"), prefix: false)
          end

          private

          def valid?(image)
            checksums = ::File.read(platform_image_checksum_path(image)).split("\n")
            iso_checksum = checksums.grep(/\.iso/).first.match(/^[^\s]+/).to_s
            Checksum.new(platform_image_path(image), iso_checksum).valid?
          end

          def images_dir
            env.home_path.join('smartos', 'platform_images')
          end

          def checksums_dir
            env.home_path.join('smartos', 'checksums')
          end

          def setup_smartos_directories
            env.setup_home_path
            FileUtils.mkdir_p(images_dir)
            FileUtils.mkdir_p(checksums_dir)
          end

          def platform_image_root
            "https://us-east.manta.joyent.com"
          end

          def platform_image_path(image)
            images_dir.join("#{image}.iso")
          end

          def platform_image_url(image)
            "#{platform_image_root}/Joyent_Dev/public/SmartOS/#{image}/smartos-#{image}.iso"
          end

          def platform_image_checksum_path(image)
            checksums_dir.join("#{image}.txt")
          end

          def platform_image_checksum_url(image)
            "#{platform_image_root}/Joyent_Dev/public/SmartOS/#{image}/md5sums.txt"
          end
        end
      end
    end
  end
end

