module Vagrant
  module Smartos
    module Zones
      module Action
        require_relative 'action/imgadm_import'
        require_relative 'action/zone_create'

        class << self
          def imgadm_import
            @imgadm_import ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ImgadmImport
            end
          end

          def zone_create
            @zone_create ||= ::Vagrant::Action::Builder.new.tap do |b|
              b.use Vagrant::Smartos::Zones::Action::ZoneCreate
            end
          end
        end
      end
    end
  end
end
