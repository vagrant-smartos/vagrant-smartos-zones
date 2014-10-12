require 'vagrant'
require_relative 'multi_command'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Smartos < Vagrant.plugin('2', :command)
          include MultiCommand

          attr_accessor :host, :ui

          COMMANDS = %w(list install).freeze

          OPTION_PARSER = OptionParser.new do |o|
            o.banner = 'Usage: vagrant smartos [name]'
            o.separator ''
            o.separator 'Commands:'
            o.separator '  list               show installed SmartOS platform images'
            o.separator '  install [image]    install SmartOS platform image'
            o.separator ''
            o.separator 'Options:'
            o.separator ''
          end

          def self.synopsis
            'Manage SmartOS platform images'
          end

          def execute
            process_subcommand
          end

          private

          def host
            @env.host
          end

          def install(image)
            if image.nil?
              ui.warn 'No image given'
              ui.warn ''
              ui.warn OPTION_PARSER.to_s
              exit 1
            end

            return ui.warn('Unable to install platform image') unless host.capability?(:platform_image_install)
            host.capability(:platform_image_install, image)
          end

          def list(*_args)
            return ui.warn('Unable to list platform image') unless host.capability?(:platform_image_install)
            host.capability(:platform_image_list)
          end

          def ui
            @env.ui
          end
        end
      end
    end
  end
end
