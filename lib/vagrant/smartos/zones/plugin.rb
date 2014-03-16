require 'vagrant'

module Vagrant
  module Smartos
    module Zones
      class Plugin < Vagrant.plugin("2")
        name "smartos-zones"

        description "SmartOS local zone support"

        config "smartos" do
          load_il8n
          require_relative 'config/smartos'
          Config::Smartos
        end

        config "zone" do
          require_relative 'config/zone'
          Config::Zone
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

        guest_capability "global_zone", "imgadm_import" do
          require_relative "cap/imgadm_import"
          Cap::ImgadmImport
        end

        guest_capability "global_zone", "zone_create" do
          require_relative "cap/zone_create"
          Cap::ZoneCreate
        end

        class << self
          def load_il8n
            I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
            I18n.reload!
          end

          def manage_zones(hook)
            hook.before(::Vagrant::Action::Builtin::Provision, Vagrant::Smartos::Zones::Action.zone_create)
            hook.before(::Vagrant::Action::Builtin::Provision, Vagrant::Smartos::Zones::Action.imgadm_import)
          end
        end

        action_hook(:image_import, :machine_action_up, &method(:manage_zones))
        action_hook(:image_import, :machine_action_reload, &method(:manage_zones))
        action_hook(:image_import, :machine_action_provision, &method(:manage_zones))
      end
    end
  end
end
