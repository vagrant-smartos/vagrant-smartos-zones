require 'vagrant/smartos/zones/cap/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        module ZoneGate
          class Install < Cap::Base
            cap_method :zone_gate_install

            LOCAL_FILES_FOLDER = File.expand_path('../../../../../../../files', __FILE__)
            LOCAL_ZONEGATE_FOLDER = File.join(LOCAL_FILES_FOLDER, 'zonegate')
            LOCAL_SMF_MANIFEST = File.join(LOCAL_FILES_FOLDER, 'smf', 'zonegate.xml')
            SMF_TMP_FOLDER = '/usbkey/vagrant'
            SMF_FOLDER = '/opt/custom/smf'
            ZONEGATE_FOLDER = '/opt/custom/method'

            def execute
              ui.info 'Installing ZoneGate'

              create_zonegate_folder
              upload_zonegate
              install_zonegate
            end

            def create_zonegate_folder
              machine.communicate.execute("#{sudo} mkdir -p %s/zonegate" % ZONEGATE_FOLDER)
              machine.communicate.execute("#{sudo} chown vagrant:other %s/zonegate" % ZONEGATE_FOLDER)
            end

            def upload_zonegate
              machine.communicate.upload(LOCAL_ZONEGATE_FOLDER, ZONEGATE_FOLDER)
              machine.communicate.upload(LOCAL_SMF_MANIFEST, '%s/zonegate.xml' % SMF_TMP_FOLDER)
            end

            def install_zonegate
              machine.communicate.execute("#{sudo} mv %s/zonegate.xml %s/zonegate.xml" % [SMF_TMP_FOLDER, SMF_FOLDER])
              machine.communicate.execute("#{sudo} chown root:root %s/zonegate.xml" % SMF_FOLDER)
              machine.communicate.execute("#{sudo} svccfg import %s/zonegate.xml" % SMF_FOLDER)
            end
          end
        end
      end
    end
  end
end
