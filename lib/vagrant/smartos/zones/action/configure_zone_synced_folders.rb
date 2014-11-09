require 'vagrant/smartos/zones/util/zone_info'
require 'vagrant/smartos/zones/util/zone_user'
require 'vagrant/smartos/zones/util/zone_group'
require 'vagrant/smartos/zones/action/helper'

# rubocop:disable all
module Vagrant
  module Smartos
    module Zones
      module Action
        class ConfigureZoneSyncedFolders
          include Helper

          def initialize(app, env)
            @app = app
            @env = env
          end

          def call(env)
            app.call(env)

            if zones_supported?
              zone = Vagrant::Smartos::Zones::Util::ZoneInfo.new(machine).show(machine.config.zone.name)

              machine.config.zone.synced_folders.each do |folder|
                configure_synced_folder(zone, folder)
              end
            end
          end

          def configure_synced_folder(zone, folder)
            host_path, guest_path, args = folder
            path = "/zones/#{zone.uuid}/root#{guest_path}"
            type = args.delete(:type) { |el| :rsync }

            username = args[:owner] || 'vagrant'
            groupname = args[:group] || 'vagrant'
            user = Vagrant::Smartos::Zones::Util::ZoneUser.new(machine, zone).find(username)
            group = Vagrant::Smartos::Zones::Util::ZoneGroup.new(machine, zone).find(groupname)

            machine.config.vm.synced_folders[path] = {
              disabled: false,
              guestpath: path,
              hostpath: host_path,
              type: type.to_sym,
              owner: user.uid,
              group: group.gid
            }.merge(args || {})
          end
        end
      end
    end
  end
end
