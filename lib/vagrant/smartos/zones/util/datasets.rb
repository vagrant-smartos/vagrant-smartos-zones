module Vagrant
  module Smartos
    module Zones
      module Util
        class Datasets
          attr_reader :env, :machine

          def initialize(env, machine = nil)
            @env = env
            @machine = machine
            setup_smartos_directories
          end

          def list
            ui.info(datasets.join("\n"), prefix: false)
          end

          protected

          def setup_smartos_directories
            env.setup_home_path if env.respond_to?(:setup_home_path)
            FileUtils.mkdir_p(dataset_dir)
          end

          private

          def ui
            env.respond_to?(:ui) ? env.ui : env[:ui]
          end

          def home_path
            env.respond_to?(:home_path) ? env.home_path : env[:home_path]
          end

          def datasets
            Dir[dataset_dir.join('*')].map do |f|
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
