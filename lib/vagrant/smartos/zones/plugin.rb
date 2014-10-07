require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      class Plugin < Vagrant.plugin("2")
        name "smartos-zones"

        description "SmartOS zone support"

        communicator('smartos') do
          require_relative 'communicator/smartos'
          Communicator::Smartos
        end

        config "global_zone" do
          load_il8n
          require_relative 'config/global_zone'
          Config::GlobalZone
        end

        config "zone" do
          require_relative 'config/zone'
          Config::Zone
        end

        command "global-zone" do
          require_relative 'commands/global_zone'
          Command::GlobalZone
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

        guest_capability "global_zone", "create_gz_vnic" do
          require_relative "cap/create_gz_vnic"
          Cap::CreateGZVnic
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

        guest_capability "global_zone", "zone_gate_enable" do
          require_relative "cap/zone_gate/enable"
          Cap::ZoneGate::Enable
        end

        guest_capability "global_zone", "zone_gate_install" do
          require_relative "cap/zone_gate/install"
          Cap::ZoneGate::Install
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
