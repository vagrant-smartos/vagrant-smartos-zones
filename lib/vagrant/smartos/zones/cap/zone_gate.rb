module Vagrant
  module Smartos
    module Zones
      module Cap
        class ZoneGate
          def self.zone_gate(machine)
            sudo = machine.config.smartos.suexec_cmd
            machine.ui.info "Installing ZoneGate"

            smf_tmp_folder = '/usbkey/vagrant'
            smf_folder = '/opt/custom/smf'

            machine.communicate.execute("#{sudo} mkdir -p %s/zonegate" % zonegate_folder)
            machine.communicate.execute("#{sudo} chown vagrant:other %s/zonegate" % zonegate_folder)

            machine.communicate.upload(local_zonegate_folder, zonegate_folder)
            machine.communicate.upload(local_smf_manifest, '%s/zonegate.xml' % smf_tmp_folder)

            machine.communicate.execute("#{sudo} mv %s/zonegate.xml %s/zonegate.xml" % [smf_tmp_folder, smf_folder])
            machine.communicate.execute("#{sudo} chown root:root %s/zonegate.xml" % smf_folder)

            machine.communicate.execute("#{sudo} svccfg import %s/zonegate.xml" % smf_folder)
          end

          def self.local_files_folder
            File.expand_path('../../../../../../files', __FILE__)
          end

          def self.local_zonegate_folder
            File.join(local_files_folder, 'zonegate')
          end

          def self.local_smf_manifest
            File.join(local_files_folder, 'smf', 'zonegate.xml')
          end

          def self.zonegate_folder
            '/opt/custom/method'
          end
        end
      end
    end
  end
end
