require 'securerandom'
require 'vagrant/smartos/zones/util/datasets'

module Vagrant
  module Smartos
    module Zones
      module Util
        class Datasets
          class Manifest
            attr_reader :name, :env

            def initialize(name, env)
              @name = name
              @env = env
            end

            def to_json
              {
                'creator_name' => 'vagrant-smartos-zones',
                'creator_uuid' => creator_uuid,
                'description' => name,
                'files' => files,
                'name' => name,
                'os' => 'smartos',
                'published_at' => '2015-06-15T15:13:08.425Z',
                'type' => 'zone-dataset',
                'urn' => urn,
                'uuid' => uuid,
                'version' => '1.0.0'
              }.to_json
            end

            private

            def files
              [
                {
                  'path' => "#{name}.zfs.bz2",
                  'sha1' => sha1,
                  'size' => size
                }
              ]
            end

            def creator_uuid
              @creator ||= SecureRandom.uuid
            end

            def sha1
              Datasets.new(env).sha1(name)
            end

            def size
              Datasets.new(env).size(name)
            end

            def urn
              "smartos:vagrant-smartos-zones:#{name}:1.0.0"
            end

            def uuid
              @uuid ||= SecureRandom.uuid
            end
          end
        end
      end
    end
  end
end
