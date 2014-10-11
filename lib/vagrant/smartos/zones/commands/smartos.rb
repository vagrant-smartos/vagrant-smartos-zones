require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Smartos < Vagrant.plugin('2', :command)
          attr_accessor :host, :ui

          def self.synopsis
            'Manage SmartOS platform images'
          end

          def execute
            options = {}

            opts = OptionParser.new do |o|
              o.banner = 'Usage: vagrant smartos [name]'
              o.separator ''
              o.separator 'Commands:'
              o.separator '  list               show installed SmartOS platform images'
              o.separator '  install [image]    install SmartOS platform image'
              o.separator ''
              o.separator 'Options:'
              o.separator ''
            end

            argv = parse_options(opts)
            return unless argv

            @host = @env.host
            @ui = @env.ui

            case argv.shift
            when 'list'
              list
            when 'install'
              install argv.shift, opts
            else
              ui.warn opts.to_s, prefix: false
              exit 1
            end
          end

          def install(image, opts)
            if image.nil?
              ui.warn 'No image given'
              ui.warn ''
              ui.warn opts.to_s
              exit 1
            end

            if host.capability?(:platform_image_install)
              host.capability(:platform_image_install, image)
            else
              ui.warn 'Unable to install platform images'
            end
          end

          def list
            if host.capability?(:platform_image_list)
              host.capability(:platform_image_list)
            else
              ui.warn 'Unable to list platform images'
            end
          end
        end
      end
    end
  end
end
