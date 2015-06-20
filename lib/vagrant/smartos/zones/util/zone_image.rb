require 'vagrant/smartos/zones/models/config'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneImage
          attr_reader :machine

          def initialize(machine)
            @machine = machine
          end

          def image
            machine.config.zone.image
          end

          def install_override?
            !!override
          end

          def override
            plugin_config["dataset.#{image}"]
          end

          def override_uuid
            @override_uuid ||= manifest.uuid
          end

          private

          def plugin_config
            @plugin_config ||= Models::Config.config(machine.env).hash
          end

          def manifest
            @manifest ||= Util::Datasets::Manifest.new(override, machine.env).load!
          end
        end
      end
    end
  end
end
