require 'vagrant/smartos/zones/cap/base'

module Vagrant
  module Smartos
    module Zones
      module Cap
        class CreateGZVnic < Base
          cap_method :create_gz_vnic

          def execute
            return unless machine.communicate.test('test -d %s' % vm_tmp_folder)

            ui.info 'Installing vnic in global zone'
            sudo = machine.config.smartos.suexec_cmd

            machine.communicate.upload(create_vnic_script, '%s/create_gz_vnic' % vm_tmp_folder)
            machine.communicate.upload(vnic_smf_manifest, '%s/create-gz-vnic.xml' % vm_tmp_folder)

            machine.communicate.execute("#{sudo} mv %s/create_gz_vnic /opt/custom/method" % vm_tmp_folder)
            machine.communicate.execute("#{sudo} mv %s/create-gz-vnic.xml /opt/custom/smf" % vm_tmp_folder)

            machine.communicate.execute("#{sudo} svccfg import /opt/custom/smf/create-gz-vnic.xml")
            machine.communicate.execute("#{sudo} svcadm enable -s create-gz-vnic")
          end

          def local_files_folder
            File.expand_path('../../../../../../files', __FILE__)
          end

          def create_vnic_script
            File.join(local_files_folder, 'gz_vnic', 'create_gz_vnic')
          end

          def vnic_smf_manifest
            File.join(local_files_folder, 'smf', 'create-gz-vnic.xml')
          end

          def vm_tmp_folder
            '/usbkey/vagrant'
          end
        end
      end
    end
  end
end
