require 'vagrant/smartos/zones/models/zone_user'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneUser
          attr_reader :machine, :zone

          def initialize(machine, zone)
            @machine = machine
            @zone = zone
          end

          def find(username)
            Models::ZoneUser.new.tap do |u|
              u.name = username
              machine.communicate.gz_execute("#{sudo} zlogin #{zone.uuid} id -u #{username}") do |_type, output|
                u.uid = output.chomp
              end
            end
          end

          private

          def sudo
            machine.config.smartos.suexec_cmd
          end
        end
      end
    end
  end
end
