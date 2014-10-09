module Vagrant
  module Smartos
    module Zones
      class Plugin < Vagrant.plugin("2")
        manage_zones = lambda do |hook|
          require_relative 'action'
          hook.before(::VagrantPlugins::ProviderVirtualBox::Action::PrepareForwardedPortCollisionParams, Vagrant::Smartos::Zones::Action.forward_gz_ports)
          hook.after(::VagrantPlugins::ProviderVirtualBox::Action::SaneDefaults, Vagrant::Smartos::Zones::Action.virtualbox_platform_iso)
          hook.after(::Vagrant::Action::Builtin::WaitForCommunicator, Vagrant::Smartos::Zones::Action.create_gz_vnic)

          hook.after(Vagrant::Smartos::Zones::Action::CreateGZVnic, Vagrant::Smartos::Zones::Action.install_zone_gate)
          hook.after(Vagrant::Smartos::Zones::Action::ZoneGate::Install, Vagrant::Smartos::Zones::Action.zone_create)
          hook.after(Vagrant::Smartos::Zones::Action::Zone::Create, Vagrant::Smartos::Zones::Action.configure_zone_synced_folders)
          hook.after(Vagrant::Smartos::Zones::Action::Zone::Create, Vagrant::Smartos::Zones::Action.zone_start)

          # Currently if this runs before a zone is created, other capabilities (such as creating zone users)
          # fail with the error that the machine is not ready for guest communication.
          hook.after(Vagrant::Smartos::Zones::Action::Zone::Create, Vagrant::Smartos::Zones::Action.enable_zone_gate)
          hook.after(Vagrant::Smartos::Zones::Action::ConfigureZoneSyncedFolders, Vagrant::Action::Builtin::SyncedFolders)
        end

        zone_start = lambda do |hook|
          require_relative 'action'
          hook.after(::Vagrant::Action::Builtin::WaitForCommunicator, Vagrant::Smartos::Zones::Action.zone_start)
        end

        zone_stop = lambda do |hook|
          require_relative 'action'
          hook.before(::Vagrant::Action::Builtin::GracefulHalt, Vagrant::Smartos::Zones::Action.zone_stop)
        end

        action_hook('smartos-zones-up', :machine_action_up, &manage_zones)
        action_hook('smartos-zones-reload', :machine_action_reload, &manage_zones)
        action_hook('smartos-zones-provision', :machine_action_provision, &manage_zones)
        action_hook('smartos-zones-halt', :machine_action_halt, &zone_stop)
        action_hook('smartos-zones-resume', :machine_action_resume, &zone_start)
      end
    end
  end
end
