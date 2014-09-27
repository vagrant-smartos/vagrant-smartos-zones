module Vagrant
  module Smartos
    module Zones
      class Plugin < Vagrant.plugin("2")
        manage_zones = lambda do |hook|
          require_relative 'action'
          hook.before(::VagrantPlugins::ProviderVirtualBox::Action::ForwardPorts, Vagrant::Smartos::Zones::Action.forward_gz_ports)
          hook.after(::VagrantPlugins::ProviderVirtualBox::Action::SaneDefaults, Vagrant::Smartos::Zones::Action.virtualbox_platform_iso)
          hook.after(::Vagrant::Action::Builtin::WaitForCommunicator, Vagrant::Smartos::Zones::Action.create_gz_vnic)

          hook.after(Vagrant::Smartos::Zones::Action::CreateGZVnic, Vagrant::Smartos::Zones::Action.install_zone_gate)
          hook.after(Vagrant::Smartos::Zones::Action::ZoneGate, Vagrant::Smartos::Zones::Action.zone_create)
          hook.after(Vagrant::Smartos::Zones::Action::ZoneCreate, Vagrant::Smartos::Zones::Action.configure_zone_synced_folders)
          hook.after(Vagrant::Smartos::Zones::Action::ConfigureZoneSyncedFolders, Vagrant::Action::Builtin::SyncedFolders)
        end

        action_hook('smartos-zones-up', :machine_action_up, &manage_zones)
        action_hook('smartos-zones-reload', :machine_action_reload, &manage_zones)
        action_hook('smartos-zones-provision', :machine_action_provision, &manage_zones)
        action_hook('smartos-zones-resume', :machine_action_resume, &manage_zones)
      end
    end
  end
end
