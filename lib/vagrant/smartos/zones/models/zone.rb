require 'vagrant/smartos/zones/util/global_zone/helper'

module Vagrant
  module Smartos
    module Zones
      module Models
        class Zone
          include Util::GlobalZone::Helper

          attr_accessor :machine, :name, :state, :uuid, :brand, :image

          def self.find(machine, name)
            zone_hash = {}
            finder = "pfexec vmadm lookup -j -o uuid,alias,state,image_uuid,brand alias=#{name}"
            with_gz(machine, finder) do |output|
              zone_hash.merge!(JSON.parse(output).first)
            end
            from_hash(zone_hash)
          end

          def self.from_hash(zone, machine = nil)
            new.tap do |z|
              z.machine = machine
              z.name = zone['alias']
              z.uuid = zone['uuid']
              z.brand = zone['brand']
              z.state = zone['state']
              z.image = zone['image_uuid']
            end
          end

          def running?
            state == 'running'
          end

          def lx_brand?
            brand == 'lx'
          end

          def test(cmd)
            command = "pfexec zlogin #{uuid} #{cmd}"
            machine.communicate.gz_test(command)
          end

          def zlogin(cmd, options = {})
            command = "pfexec zlogin #{uuid} #{cmd}"
            with_gz(command, options) do |output|
              yield output if block_given?
            end
          end
        end
      end
    end
  end
end
