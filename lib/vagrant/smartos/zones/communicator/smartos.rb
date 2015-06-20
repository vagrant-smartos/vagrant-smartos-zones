require 'vagrant/smartos/zones/util/global_zone/connection'
require 'vagrant/smartos/zones/util/rsync'

module Vagrant
  module Smartos
    module Zones
      module Communicator
        class Smartos < Vagrant.plugin('2').manager.communicators[:ssh]
          def initialize(machine)
            @machine = machine
            super
          end

          def gz_download(from, to = nil)
            @logger.debug("Downloading from global zone: #{from} to #{to}")

            if gz_rsync_connector.available?
              gz_rsync_connector.download(from, to)
            else
              gz_scp_connect do |scp|
                scp.download!(from, to) do |_ch, name, sent, total|
                  percent = (sent.to_f / total) * 100
                  print "#{name}: #{sent}/#{total} : #{percent.to_i}%\r"
                  $stdout.flush
                end
              end
            end
          end

          def gz_upload(from, to)
            @logger.debug("Uploading to global zone: #{from} to #{to}")

            if gz_rsync_connector.available?
              gz_rsync_connector.upload(from, to)
            else
              gz_scp_connect do |scp|
                scp.upload!(from, to) do |_ch, name, sent, total|
                  percent = (sent.to_f / total) * 100
                  print "#{name}: #{sent}/#{total} : #{percent.to_i}%\r"
                  $stdout.flush
                end
              end
            end
          end

          # rubocop:disable Metrics/MethodLength
          def gz_execute(command, opts = {}, &block)
            opts = {
              error_check: true,
              error_class: Vagrant::Errors::VagrantError,
              error_key:   :ssh_bad_exit_status,
              good_exit:   0,
              command:     command,
              shell:       nil,
              sudo:        false
            }.merge(opts)

            opts[:good_exit] = Array(opts[:good_exit])

            # Connect via SSH and execute the command in the shell.
            stdout = ''
            stderr = ''
            global_zone_connector.connect

            begin
              generic_ssh_info = @connection_ssh_info
              @connection_ssh_info = global_zone_connector.ssh_info

              exit_status = global_zone_connector.with_connection do |connection|
                shell_opts = {
                  sudo: opts[:sudo],
                  shell: opts[:shell]
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

          def gz_scp_connect
            global_zone_connector.with_connection do |connection|
              yield connection.scp
            end
          rescue Net::SCP::Error => e
            raise Vagrant::Errors::SCPUnavailable if e.message =~ /\(127\)/
            raise
          end

          def gz_test(command, opts = nil)
            opts = { error_check: false }.merge(opts || {})
            gz_execute(command, opts) == 0
          end

          private

          def global_zone_connector
            @global_zone_connector ||= Vagrant::Smartos::Zones::Util::GlobalZone::Connection.new(@machine, @logger)
          end

          def gz_rsync_connector
            @gz_rsync_connector ||= Vagrant::Smartos::Zones::Util::Rsync.new(global_zone_connector.connect)
          end
        end
      end
    end
  end
end
