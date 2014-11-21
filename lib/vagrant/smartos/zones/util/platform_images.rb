require 'vagrant/smartos/zones/util/checksum'
require 'vagrant/smartos/zones/util/downloader'
require 'vagrant/util/downloader'

module Vagrant
  module Smartos
    module Zones
      module Util
        class PlatformImages
          attr_reader :env, :image, :machine

          def initialize(env, machine = nil)
            @env = env
            @machine = machine
            setup_smartos_directories
          end

          def get_platform_image(image)
            @image = image
            @image = latest_remote_or_current_image if image == 'latest'
            install(image)
            platform_image_path
          end

          def install(image)
            @image = image
            @image = latest_remote_or_current_image if image == 'latest'
            if ::File.exist?(platform_image_path) && valid?
              ui.info "SmartOS platform image #{image} exists"
            else
              download_checksum_file
              download_platform_image
            end
          end

          def list
            ui.info(images.join("\n"), prefix: false)
          end

          def latest
            latest_html = Zones::Util::Downloader.new(platform_image_latest_url).read
            latest = latest_html.match(/(\d{8}T\d{6}Z)/)
            return unless latest
            latest[1]
          end

          protected

          def setup_smartos_directories
            env.setup_home_path if env.respond_to?(:setup_home_path)
            FileUtils.mkdir_p(images_dir)
            FileUtils.mkdir_p(checksums_dir)
          end

          def download_checksum_file
            return if machine && machine.config.global_zone.platform_image_url
            ui.info "Downloading checksums for SmartOS platform image #{image}"
            Zones::Util::Downloader.get(platform_image_checksum_url, platform_image_checksum_path)
          end

          def download_platform_image
            ui.info "Downloading SmartOS platform image #{image}"
            Vagrant::Util::Downloader.new(platform_image_url, platform_image_path, ui: ui).download!
          end

          private

          def ui
            env.respond_to?(:ui) ? env.ui : env[:ui]
          end

          def home_path
            env.respond_to?(:home_path) ? env.home_path : env[:home_path]
          end

          def valid?
            return true if machine && machine.config.global_zone.platform_image_url
            checksums = ::File.read(platform_image_checksum_path).split("\n")
            iso_checksum = checksums.grep(/\.iso/).first.match(/^[^\s]+/).to_s
            Checksum.new(platform_image_path, iso_checksum).valid?
          end

          def images
            Dir[images_dir.join('*')].map do |f|
              File.basename(f, '.iso')
            end.sort
          end

          def images_dir
            home_path.join('smartos', 'platform_images')
          end

          def checksums_dir
            home_path.join('smartos', 'checksums')
          end

          def latest_remote_or_current_image
            return latest if latest
            ui.info 'Unable to read remote latest platform image, using local'
            images.last
          end

          def platform_image_root
            'https://us-east.manta.joyent.com'
          end

          def platform_image_path
            images_dir.join("#{image}.iso")
          end

          def platform_image_url
            return machine.config.global_zone.platform_image_url if machine && machine.config.global_zone.platform_image_url
            "#{platform_image_root}/Joyent_Dev/public/SmartOS/#{image}/smartos-#{image}.iso"
          end

          def platform_image_latest_url
            "#{platform_image_root}/Joyent_Dev/public/SmartOS/latest.html"
          end

          def platform_image_checksum_path
            checksums_dir.join("#{image}.txt")
          end

          def platform_image_checksum_url
            "#{platform_image_root}/Joyent_Dev/public/SmartOS/#{image}/md5sums.txt"
          end
        end
      end
    end
  end
end
