require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      class Plugin < Vagrant.plugin("2")
        name "smartos-zones"

        description "SmartOS zone support"

        config "global_zone" do
          load_il8n
          require_relative 'config/global_zone'
          Config::GlobalZone
        end

        config "zone" do
          require_relative 'config/zone'
          Config::Zone
        end

        command "smartos" do
          require_relative 'commands/smartos'
          Command::Smartos
        end

        command "zones" do
          require_relative 'commands/zones'
          Command::Zones
        end

        command "zlogin" do
          require_relative 'commands/zlogin'
          Command::Zlogin
        end

        guest "global_zone", "smartos" do
          require_relative 'guest'
          Guest
        end

        guest_capability "global_zone", "create_zone_users" do
          require_relative "cap/create_zone_users"
          Cap::CreateZoneUsers
        end

        guest_capability "global_zone", "imgadm_import" do
          require_relative "cap/imgadm_import"
          Cap::ImgadmImport
        end

        guest_capability "global_zone", "zone_create" do
          require_relative "cap/zone_create"
          Cap::ZoneCreate
        end

        host_capability  "bsd", "platform_image_install" do
          require_relative "cap/platform_image/install"
          Cap::PlatformImage::Install
        end

        host_capability  "bsd", "platform_image_list" do
          require_relative "cap/platform_image/list"
          Cap::PlatformImage::List
        end

        class << self
          def load_il8n
            I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
            I18n.reload!
          end
        end
      end
    end
  end
end

require_relative 'hooks'
