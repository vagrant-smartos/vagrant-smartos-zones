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

          def get_platform_image(image)
            install(image)
            platform_image_path(image)
          end

          def install(image)
            if ::File.exist?(platform_image_path(image)) && valid?(image)
              ui.info "SmartOS platform image #{image} exists"
            else
              ui.info "Downloading checksums for SmartOS platform image #{image}"
              Downloader.get(platform_image_checksum_url(image), platform_image_checksum_path(image))
              ui.info "Downloading SmartOS platform image #{image}"
              Downloader.get(platform_image_url(image), platform_image_path(image))
            end
          end

          def list
            images = Dir[images_dir.join('*')].map do |f|
              File.basename(f, '.iso')
            end

            ui.info(images.join("\n"), prefix: false)
          end

          private

          def ui
            env.respond_to?(:ui) ? env.ui : env[:ui]
          end

          def home_path
            env.respond_to?(:home_path) ? env.home_path : env[:home_path]
          end

          def valid?(image)
            checksums = ::File.read(platform_image_checksum_path(image)).split("\n")
            iso_checksum = checksums.grep(/\.iso/).first.match(/^[^\s]+/).to_s
            Checksum.new(platform_image_path(image), iso_checksum).valid?
          end

          def images_dir
            home_path.join('smartos', 'platform_images')
          end

          def checksums_dir
            home_path.join('smartos', 'checksums')
          end

          def setup_smartos_directories
            env.setup_home_path if env.respond_to?(:setup_home_path)
            FileUtils.mkdir_p(images_dir)
            FileUtils.mkdir_p(checksums_dir)
          end

          def platform_image_root
            'https://us-east.manta.joyent.com'
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
