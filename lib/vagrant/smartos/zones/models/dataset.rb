require 'vagrant/smartos/zones/models/snapshot'
require 'vagrant/smartos/zones/util/datasets'
require 'vagrant/smartos/zones/util/datasets/manifest'
require 'vagrant/smartos/zones/util/global_zone/helper'

module Vagrant
  module Smartos
    module Zones
      module Models
        class Dataset
          include Util::GlobalZone::Helper

          attr_reader :name, :zone, :machine

          def initialize(name, zone, machine)
            @name = name
            @zone = zone
            @machine = machine
          end

          def self.create(name, zone)
            new(name, zone).create
          end

          def self.install(name, machine)
            new(name, nil, machine).install
          end

          def create
            Zones::Util::Datasets.new(machine.env).setup_smartos_directories
            prepare_gz
            # create_dataset
            # download
            write_manifest
          end

          def exists?
            cmd = 'ls %s 2>/dev/null' % remote_filename
            with_gz(cmd) do |output|
              return true if output.strip == remote_filename
            end
            false
          end

          def install
            prepare_gz
            upload
            self
          end

          def remote_filename
            '/zones/vagrant/%s' % filename
          end

          private

          def prepare_gz
            with_gz('pfexec mkdir /zones/vagrant')
            with_gz('pfexec chown vagrant:vagrant /zones/vagrant')
          end

          def create_dataset
            return machine.ui.info('Dataset already exists in global zone') if exists?
            Models::Snapshot.around(zone) do
              machine.ui.info(I18n.t('vagrant.smartos.zones.commands.dataset.prepare_image'))
              zone.zlogin('\'find /var/log -type f -exec truncate --size 0 {} \;\'')
              zone.zlogin('sm-prepare-image -y')
              machine.ui.info(I18n.t('vagrant.smartos.zones.commands.dataset.stop_zone'))
              zone.stop
              Models::Snapshot.around(zone) do |snapshot|
                machine.ui.info(I18n.t('vagrant.smartos.zones.commands.dataset.save'))
                cmd = 'pfexec /usr/bin/bash -l -c "/usr/sbin/zfs send %s | /usr/bin/bzip2 > %s"'
                with_gz(cmd % [snapshot.path, remote_filename])
              end
            end
            machine.ui.info(I18n.t('vagrant.smartos.zones.commands.dataset.start_zone'))
            zone.start
          end

          def download
            machine.ui.info 'Downloading %s' % filename
            machine.communicate.gz_download(remote_filename, local_filename)
          end

          def upload
            machine.ui.info 'Installing %s in global zone' % filename
            machine.communicate.gz_upload(local_filename, remote_filename)
          end

          def write_manifest
            Zones::Util::Datasets::Manifest.new(name, machine.env).write!
          end

          def filename
            '%s.zfs.bz2' % name
          end

          def local_filename
            machine.env.home_path.join('smartos', 'datasets', filename).to_s
          end
        end
      end
    end
  end
end
