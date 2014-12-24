require 'vagrant/smartos/zones/util/global_zone/helper'
require 'vagrant/smartos/zones/util/public_key'

module Vagrant
  module Smartos
    module Zones
      module Util
        class ZoneProject
          include GlobalZone::Helper

          attr_reader :machine, :zone

          def initialize(machine, zone)
            @machine = machine
            @zone = zone
          end

          def create(project, users, comment)
            return if zone.lx_brand?
            zone.zlogin("projadd -c \"#{comment}\" -U #{users.join(',')} #{project}")
          end
        end
      end
    end
  end
end
