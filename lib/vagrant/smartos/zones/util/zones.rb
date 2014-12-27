require 'vagrant/smartos/zones/models/config'
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
        # Service object for creating zones
        #
        # Wraps up creation of associated things within a zone
        #
        class Zones
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
            with_zone(name) do |zone|
              create_zone_users(zone)
              configure_pkgsrc_mirror(zone)
            end
          end

          def update(name)
            with_zone(name) do |zone|
              machine.ui.info "Updating zone #{name}..."
              with_gz("echo '#{zone_json}' | #{sudo} vmadm update #{zone.uuid}")
            end
          end

          private

          def configure_pkgsrc_mirror(zone)
            return if zone.lx_brand?
            return unless pkgsrc_mirror
            machine.ui.info(I18n.t('vagrant.smartos.zones.pkgsrc.mirror',
                                   uuid: zone.uuid, mirror: pkgsrc_mirror))
            zone.zlogin("sed -i -e \\'s@http://pkgsrc.joyent.com@#{pkgsrc_mirror}@\\' /opt/local/etc/pkgin/repositories.conf")
          end

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

          def pkgsrc_mirror
            plugin_config['local.pkgsrc']
          end

          def plugin_config
            @plugin_config ||= Models::Config.config(machine.env).hash
          end

          def zone_json
            Util::ZoneJson.new(machine).to_json
          end

          def with_zone(name)
            Models::Zone.find(machine, name).tap { |zone| yield zone }
          end
        end
      end
    end
  end
end
