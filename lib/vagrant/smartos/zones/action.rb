module Vagrant
  module Smartos
    module Zones
      module Action
        require_relative 'action/imgadm_import'

        class << self
          def imgadm_import
            @imgadm_import ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ImgadmImport
            end
          end
        end
      end
    end
  end
end
