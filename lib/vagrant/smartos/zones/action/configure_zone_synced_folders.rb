require 'vagrant/smartos/zones/util/zone_info'
require 'vagrant/smartos/zones/util/zone_user'
require 'vagrant/smartos/zones/util/zone_group'
require_relative 'helper'

module Vagrant
  module Smartos
    module Zones
      module Action
        class ConfigureZoneSyncedFolders
          include Helper

          def initialize(app, env)
            @app = app
          end

          def call(env)
            machine = env[:machine]
            guest = machine.guest

            if zones_supported?
              zone = Vagrant::Smartos::Zones::Util::ZoneInfo.new(machine).show(machine.config.zone.name)

              machine.config.zone.synced_folders.each do |folder|
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

              @app.call(env)
            end
          end
        end
      end
    end
  end
end
