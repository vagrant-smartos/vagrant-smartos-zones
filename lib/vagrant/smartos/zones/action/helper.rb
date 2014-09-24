module Vagrant
  module Smartos
    module Zones
      module Action
        module Helper

          private

          def zones_supported?
            @zones_supported ||= @guest.capability?(:imgadm_import)
          end
        end
      end
    end
  end
end

