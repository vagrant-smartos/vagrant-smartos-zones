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

            def write!
              File.open(local_filename, 'w') do |f|
                f.write to_json
              end
              self
            end

            def load!
              json = JSON.load(File.read(local_filename))
              @creator = json['creator_uuid']
              @uuid = json['uuid']
              self
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

            def local_filename
              env.home_path.join('smartos', 'datasets', manifest_filename).to_s
            end

            def remote_filename
              '/zones/vagrant/%s' % manifest_filename
            end

            def uuid
              @uuid ||= SecureRandom.uuid
            end

            private

            def files
              [
                {
                  'path' => "#{name}.zfs.gz",
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

            def manifest_filename
              '%s.dsmanifest' % name
            end
          end
        end
      end
    end
  end
end
