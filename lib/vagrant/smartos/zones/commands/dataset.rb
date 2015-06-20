require 'vagrant'
require_relative 'multi_command'
require 'vagrant/smartos/zones/errors'
require 'vagrant/smartos/zones/models/dataset'
require 'vagrant/smartos/zones/models/zone'

module Vagrant
  module Smartos
    module Zones
      module Command
        class Dataset < Vagrant.plugin('2', :command)
          include MultiCommand

          attr_accessor :host, :ui

          COMMANDS = %w(list create delete install).freeze

          OPTION_PARSER = OptionParser.new do |o|
            o.banner = 'Usage: vagrant dataset [subcommand] [options]'
            o.separator ''
            o.separator 'Commands:'
            o.separator '  create [zone] [name]         create a local dataset [name] from running zone [zone]'
            o.separator '  delete [name]                delete a local dataset [name]'
            o.separator '  list                         show all locally installed datasets'
            o.separator '  install [url]                download a dataset to the local machine'
            o.separator ''
            o.separator 'Options:'
            o.separator ''
          end

          def self.synopsis
            'Manage local SmartOS datasets'
          end

          private

          def host
            @env.host
          end

          def create(zonename, dataset)
            with_zone(zonename) do |zone|
              ui.info(I18n.t('vagrant.smartos.zones.commands.dataset.create', uuid: zone.uuid, dataset: dataset))
              Models::Dataset.create(dataset, zone, zone.machine)
            end
          end

          def delete(dataset_name)
            return ui.warn('Unable to delete datasets') unless host.capability?(:dataset_delete)
            host.capability(:dataset_delete, dataset_name)
          end

          def list(*_args)
            return ui.warn('Unable to list datasets') unless host.capability?(:dataset_list)
            host.capability(:dataset_list)
          end

          def install(url)
            if url.nil?
              ui.warn 'No url given'
              ui.warn ''
              ui.warn OPTION_PARSER.to_s
              exit 1
            end

            return ui.warn('Unable to install dataset') unless host.capability?(:dataset_install)
            host.capability(:dataset_install, url)
          end

          def ui
            @env.ui
          end

          def with_zone(name)
            with_target_vms('default', single_target: true) do |machine|
              Models::Zone.find(machine, name).tap do |zone|
                yield zone
              end
            end
          rescue ZoneNotFound
            ui.warn(I18n.t('vagrant.smartos.zones.warning.zone_not_found',
                           name: name), prefix: false)
          end
        end
      end
    end
  end
end
