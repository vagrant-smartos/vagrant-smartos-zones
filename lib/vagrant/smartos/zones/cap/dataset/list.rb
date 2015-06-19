require 'vagrant/smartos/zones/util/datasets'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module Dataset
          class List
            def self.dataset_list(env)
              Zones::Util::Datasets.new(env).list
            end
          end
        end
      end
    end
  end
end
