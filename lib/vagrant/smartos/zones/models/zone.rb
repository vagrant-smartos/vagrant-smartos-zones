require 'vagrant/smartos/zones/errors'
require 'vagrant/smartos/zones/util/global_zone/helper'

module Vagrant
  module Smartos
    module Zones
      module Models
        class Zone
          include Util::GlobalZone::Helper

          attr_accessor :machine, :name, :state, :uuid, :brand, :image

          def self.all(machine)
            zones = []
            with_gz(machine, 'pfexec vmadm lookup -j') do |output|
              hashes = JSON.parse(output)
              zones += hashes.map { |h| from_hash(h, machine) }
            end
            zones
          end

          def self.find(machine, name)
            zone_hash = {}
            finder = "pfexec vmadm lookup -j -o uuid,alias,state,image_uuid,brand alias=#{name}"
            with_gz(machine, finder) do |output|
              hash = JSON.parse(output).first
              raise ZoneNotFound unless hash
              zone_hash.merge!(hash)
            end
            from_hash(zone_hash, machine)
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

          def destroy
            with_gz("pfexec vmadm delete #{uuid}")
            self.state = 'deleted'
          end

          def start
            with_gz("pfexec vmadm start #{uuid}")
          end

          def stop
            with_gz("pfexec vmadm stop #{uuid}")
          end
        end
      end
    end
  end
end
