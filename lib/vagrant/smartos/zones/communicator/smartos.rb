require 'vagrant/smartos/zones/util/global_zone/connection'

module Vagrant
  module Smartos
    module Zones
      module Communicator
        class Smartos < Vagrant.plugin("2").manager.communicators[:ssh]
          def initialize(machine)
            @machine = machine
            super
          end

          # rubocop:disable Metrics/MethodLength
          def gz_execute(command, opts={}, &block)
            opts = {
              error_check: true,
              error_class: Vagrant::Errors::VagrantError,
              error_key:   :ssh_bad_exit_status,
              good_exit:   0,
              command:     command,
              shell:       nil,
              sudo:        false,
            }.merge(opts)

            opts[:good_exit] = Array(opts[:good_exit])

            # Connect via SSH and execute the command in the shell.
            stdout = ""
            stderr = ""
            global_zone_connector.connect

            begin
              generic_ssh_info = @connection_ssh_info
              @connection_ssh_info = global_zone_connector.ssh_info

              exit_status = global_zone_connector.with_connection do |connection|
                shell_opts = {
                  sudo: opts[:sudo],
                  shell: opts[:shell],
                }

                shell_execute(connection, command, **shell_opts) do |type, data|
                  if type == :stdout
                    stdout += data
                  elsif type == :stderr
                    stderr += data
                  end

                  block.call(type, data) if block
                end
              end
            ensure
              @connection_ssh_info = generic_ssh_info
            end

            # Check for any errors
            if opts[:error_check] && !opts[:good_exit].include?(exit_status)
              # The error classes expect the translation key to be _key,
              # but that makes for an ugly configuration parameter, so we
              # set it here from `error_key`
              error_opts = opts.merge(
                _key: opts[:error_key],
                stdout: stdout,
                stderr: stderr
              )
              raise opts[:error_class], error_opts
            end

            # Return the exit status
            exit_status
          end

          def gz_test(command, opts=nil)
            opts = { error_check: false }.merge(opts || {})
            gz_execute(command, opts) == 0
          end

          private

          def global_zone_connector
            @global_zone_connector ||= Vagrant::Smartos::Zones::Util::GlobalZone::Connection.new(@machine, @logger)
          end
        end
      end
    end
  end
end
