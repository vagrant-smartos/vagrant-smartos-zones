module Vagrant
  module Smartos
    module Zones
      class Plugin < Vagrant.plugin("2")
        manage_zones = lambda do |hook|
          require_relative 'action'
          hook.after(::Vagrant::Action::Builtin::WaitForCommunicator, Vagrant::Smartos::Zones::Action.zone_create)
          hook.after(::VagrantPlugins::ProviderVirtualBox::Action::SaneDefaults, Vagrant::Smartos::Zones::Action.virtualbox_platform_iso)
        end

        action_hook('smartos-zones-up', :machine_action_up, &manage_zones)
        action_hook('smartos-zones-reload', :machine_action_reload, &manage_zones)
        action_hook('smartos-zones-provision', :machine_action_provision, &manage_zones)
      end
    end
  end
end
