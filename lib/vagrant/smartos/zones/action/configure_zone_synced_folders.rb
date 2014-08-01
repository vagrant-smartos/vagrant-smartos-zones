require 'vagrant/smartos/zones/util/zone_info'

module Vagrant
  module Smartos
    module Zones
      module Action
        class ConfigureZoneSyncedFolders
          def initialize(app, env)
            @app = app
          end

          def call(env)
            machine = env[:machine]
            guest = machine.guest

            zone = Vagrant::Smartos::Zones::Util::ZoneInfo.new(machine).show(machine.config.zone.name)
            machine.config.zone.synced_folders.each do |folder|
              host_path, guest_path, args = folder
              path = "/zones/#{zone.uuid}/root#{guest_path}"
              type = args.delete(:type) { |el| :rsync }

              machine.config.vm.synced_folders[path] = {
                disabled: false,
                guestpath: path,
                hostpath: host_path,
                type: type.to_sym
              }.merge(args || {})
            end

            @app.call(env)
          end
        end
      end
    end
  end
end
