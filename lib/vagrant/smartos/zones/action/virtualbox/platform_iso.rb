require 'vagrant/smartos/zones/util/platform_images'

module Vagrant
  module Smartos
    module Zones
      module Action
        module VirtualBox
          class PlatformISO
            attr_accessor :app, :env, :machine
            def initialize(app, env)
              @app = app
            end

            def call(env)
              @app.call(env)

              @env = env
              @machine = env[:machine]

              if requires_platform_iso?
                env[:ui].warn "Remapping platform ISO"
                machine.provider_config.customizations << remove_dvddrive
                machine.provider_config.customizations << add_platform_image
              end
            end

            private

            def requires_platform_iso?
              machine.config.global_zone.platform_image
            end

            def remove_dvddrive
              ['pre-boot', ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--medium', 'none']]
            end

            def add_platform_image
              platform_image = Vagrant::Smartos::Zones::Util::PlatformImages.new(env).get_platform_image(machine.config.global_zone.platform_image)
              ['pre-boot', ['storageattach', :id, '--storagectl', 'IDE Controller', 
                            '--port', 1, '--device', 0, '--type', 'dvddrive', 
                            '--medium', platform_image.to_s]]
            end
          end
        end
      end
    end
  end
end
