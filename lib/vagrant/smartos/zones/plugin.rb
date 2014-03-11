module Vagrant
  module Smartos
    module Zones
      class Plugin < Vagrant.plugin("2")
        name "smartos-zones"

        description "SmartOS local zone support"

        config "zone" do
          require_relative 'zone_config'
          ZoneConfig
        end

        guest "global_zone", "smartos" do
          require_relative 'guest'
          Guest
        end

        guest_capability "global_zone", "imgadm_import" do
          require_relative "cap/imgadm_import"
          Cap::ImgadmImport
        end

        class << self
          def imgadm_import(hook)
            hook.before(::Vagrant::Action::Builtin::Provision, Vagrant::Smartos::Zones::Action.imgadm_import)
          end
        end

        action_hook(:image_import, :machine_action_up, &method(:imgadm_import))
      end
    end
  end
end
