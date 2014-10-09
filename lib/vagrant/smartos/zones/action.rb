module Vagrant
  module Smartos
    module Zones
      module Action
        require_relative 'action/configure_zone_synced_folders'
        require_relative 'action/create_gz_vnic'
        require_relative 'action/forward_gz_ports'
        require_relative 'action/imgadm_import'
        require_relative 'action/zone/create'
        require_relative 'action/zone/start'
        require_relative 'action/zone/stop'
        require_relative 'action/zone_gate/enable'
        require_relative 'action/zone_gate/install'
        require_relative 'action/virtualbox/platform_iso'

        class << self
          def configure_zone_synced_folders
            @configure_zone_synced_folders ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ConfigureZoneSyncedFolders
            end
          end

          def create_gz_vnic
            @configure_zone_synced_folders ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::CreateGZVnic
            end
          end

          def enable_zone_gate
            @enable_zone_gate ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ZoneGate::Enable
            end
          end

          def forward_gz_ports
            @forward_gz_ports ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ForwardGZPorts
            end
          end

          def install_zone_gate
            @install_zone_gate ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ZoneGate::Install
            end
          end

          def virtualbox_platform_iso
            @virtualbox_platform_iso ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::VirtualBox::PlatformISO
            end
          end

          def zone_create
            @zone_create ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ImgadmImport
              b.use Vagrant::Smartos::Zones::Action::Zone::Create
            end
          end

          def zone_start
            @zone_start ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::Zone::Start
            end
          end

          def zone_stop
            @zone_stop ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::Zone::Stop
            end
          end
        end
      end
    end
  end
end
