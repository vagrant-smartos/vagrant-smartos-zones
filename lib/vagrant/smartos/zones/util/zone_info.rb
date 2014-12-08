require 'vagrant/smartos/zones/models/zone'
require 'vagrant/smartos/zones/util/global_zone/helper'
require 'vagrant/smartos/zones/util/zone_group'
require 'vagrant/smartos/zones/util/zone_json'
require 'vagrant/smartos/zones/util/zone_project'
require 'vagrant/smartos/zones/util/zone_user'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneInfo
          include GlobalZone::Helper

          attr_reader :machine

          ROOT_PASSWORD = '\$5\$90x8mAeX\$SKKNEjeztV.ruPBNf/E5y3xqGkwDv9A5KNP2S89GuB.'
          VAGRANT_PASSWORD = '\$5\$UzQ1rHU/\$o67DYOyHOOabzJt.6DwgZP2qCGoAO7aVel2bgkuIwL7'

          def initialize(machine)
            @machine = machine
          end

          def create(name)
            machine.ui.info "Creating zone #{machine.config.zone.name} with image #{machine.config.zone.image}"
            with_gz("echo '#{zone_json}' | #{sudo} vmadm create")
            show(name).tap do |zone|
              create_zone_users(zone)
            end
          end

          def destroy(name)
            show(name).tap do |zone|
              with_gz("#{sudo} vmadm delete #{zone.uuid}")
              zone.state = 'deleted'
            end
          end

          def show(name)
            zone_name = name || machine.config.zone.name
            Models::Zone.find(machine, zone_name)
          end

          def start(name)
            show(name).tap do |zone|
              with_gz("#{sudo} vmadm start #{zone.uuid}")
            end
          end

          def stop(name)
            show(name).tap do |zone|
              with_gz("#{sudo} vmadm stop #{zone.uuid}")
            end
          end

          def update(name)
            show(name).tap do |zone|
              machine.ui.info "Updating zone #{name}..."
              with_gz("echo '#{zone_json}' | #{sudo} vmadm update #{zone.uuid}")
            end
          end

          private

          def create_zone_users(zone)
            create_zone_vagrant_user(zone)
            configure_zone_passwords(zone)
          end

          def create_zone_vagrant_user(zone)
            Util::ZoneGroup.new(machine, zone).create('vagrant')
            Util::ZoneUser.new(machine, zone).create('vagrant', 'vagrant', 'Primary Administrator')
            Util::ZoneProject.new(machine, zone).create('vagrant', %w(vagrant), 'Vagrant')
          end

          def configure_zone_passwords(zone)
            overwrite_password(zone, 'root', ROOT_PASSWORD, '16151')
            overwrite_password(zone, 'vagrant', VAGRANT_PASSWORD, '16158')
          end

          def overwrite_password(zone, user, pw, ts)
            zone.zlogin("sed -i -e \\'s@#{user}:.*@#{user}:#{pw}:#{ts}::::::@\\' /etc/shadow")
          end

          def zone_json
            Util::ZoneJson.new(machine).to_json
          end
        end
      end
    end
  end
end
