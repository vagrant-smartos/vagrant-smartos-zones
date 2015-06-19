require 'digest/sha1'

module Vagrant
  module Smartos
    module Zones
      module Util
        class Datasets
          attr_reader :env, :machine

          def initialize(env, machine = nil)
            @env = env
            @machine = machine
          end

          def list
            setup_smartos_directories
            ui.info(datasets.join("\n"), prefix: false)
          end

          def setup_smartos_directories
            env.setup_home_path if env.respond_to?(:setup_home_path)
            FileUtils.mkdir_p(dataset_dir)
          end

          def sha1(name)
            Digest::SHA1.file(dataset_dir.join("#{name}.zfs.bz2")).hexdigest
          end

          def size(name)
            ::File.size(dataset_dir.join("#{name}.zfs.bz2"))
          end

          private

          def ui
            env.respond_to?(:ui) ? env.ui : env[:ui]
          end

          def home_path
            env.respond_to?(:home_path) ? env.home_path : env[:home_path]
          end

          def datasets
            Dir[dataset_dir.join('*.zfs.bz2')].map do |f|
              File.basename(f, '.zfs.bz2')
            end.sort
          end

          def dataset_dir
            home_path.join('smartos', 'datasets')
          end
        end
      end
    end
  end
end
