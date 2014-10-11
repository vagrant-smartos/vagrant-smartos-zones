require 'net/ssh'
require 'stringio'
require 'timeout'
require 'vagrant/util/retryable'
require 'vagrant/smartos/zones/util/global_zone/ssh_info'

module Vagrant
  module Smartos
    module Zones
      module Util
        module GlobalZone
          class Connection < Struct.new(:machine, :logger)
            include Vagrant::Util::Retryable

            CONNECTION_TIMEOUT = 60

            # These are the exceptions that we retry because they represent
            # errors that are generally fixed from a retry and don't
            # necessarily represent immediate failure cases.
            RETRYABLE_EXCEPTIONS = [
              Errno::EACCES,
              Errno::EADDRINUSE,
              Errno::ECONNREFUSED,
              Errno::ECONNRESET,
              Errno::ENETUNREACH,
              Errno::EHOSTUNREACH,
              Net::SSH::Disconnect,
              Timeout::Error
            ]

            class ErrorHandler < Struct.new(:error)
              # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
              def handle!
                case error.class
                when Errno::EACCES
                  # This happens on connect() for unknown reasons yet...
                  raise Vagrant::Errors::SSHConnectEACCES
                when Errno::ETIMEDOUT, Timeout::Error
                  # This happens if we continued to timeout when attempting to connect.
                  raise Vagrant::Errors::SSHConnectionTimeout
                when Net::SSH::AuthenticationFailed
                  # This happens if authentication failed. We wrap the error in our
                  # own exception.
                  raise Vagrant::Errors::SSHAuthenticationFailed
                when Net::SSH::Disconnect
                  # This happens if the remote server unexpectedly closes the
                  # connection. This is usually raised when SSH is running on the
                  # other side but can't properly setup a connection. This is
                  # usually a server-side issue.
                  raise Vagrant::Errors::SSHDisconnected
                when Errno::ECONNREFUSED
                  # This is raised if we failed to connect the max amount of times
                  raise Vagrant::Errors::SSHConnectionRefused
                when Errno::ECONNRESET
                  # This is raised if we failed to connect the max number of times
                  # due to an ECONNRESET.
                  raise Vagrant::Errors::SSHConnectionReset
                when Errno::EHOSTDOWN
                  # This is raised if we get an ICMP DestinationUnknown error.
                  raise Vagrant::Errors::SSHHostDown
                when Errno::EHOSTUNREACH
                  # This is raised if we can't work out how to route traffic.
                  raise Vagrant::Errors::SSHNoRoute
                when NotImplementedError
                  # This is raised if a private key type that Net-SSH doesn't support
                  # is used. Show a nicer error.
                  raise Vagrant::Errors::SSHKeyTypeNotSupported
                end
              end
            end

            class SSHLogger
              attr_reader :logger

              def initialize
                @io = StringIO.new
                @logger = Logger.new(@io)
              end

              def to_s
                @io.string
              end
            end

            def with_connection
              connect
              yield @connection if block_given?
            end

            # rubocop:disable Metrics/MethodLength
            def connect(**opts)
              return @connection if connection_valid?

              validate_ssh_info!
              check_ssh_key_permissions

              # Default some options
              opts[:retries] = 5 unless opts.key?(:retries)

              # Connect to SSH, giving it a few tries
              connection = nil
              begin
                logger.info('Attempting SSH connection...')
                connection = retryable(tries: opts[:retries], on: RETRYABLE_EXCEPTIONS) do
                  Timeout.timeout(CONNECTION_TIMEOUT) do
                    begin
                      ssh_logger = SSHLogger.new

                      # Setup logging for connections
                      connect_opts = common_connect_opts.dup
                      connect_opts[:logger] = ssh_logger.logger

                      if ssh_info[:proxy_command]
                        connect_opts[:proxy] = Net::SSH::Proxy::Command.new(ssh_info[:proxy_command])
                      end

                      logger.info('Attempting to connect to SSH...')
                      logger.info("  - Host: #{ssh_info[:host]}")
                      logger.info("  - Port: #{ssh_info[:port]}")
                      logger.info("  - Username: #{ssh_info[:username]}")
                      logger.info("  - Password? #{uses_password?}")
                      logger.info("  - Key Path: #{ssh_info[:private_key_path]}")

                      Net::SSH.start(ssh_info[:host], ssh_info[:username], connect_opts)
                    ensure
                      # Make sure we output the connection log
                      logger.debug('== Net-SSH connection debug-level log START ==')
                      logger.debug(ssh_logger.to_s)
                      logger.debug('== Net-SSH connection debug-level log END ==')
                    end
                  end
                end
              rescue StandardError => e
                ErrorHandler.new(e).handle!
              end

              @connection = connection
            end

            def ssh_info
              @ssh_info ||= Util::GlobalZone::SSHInfo.new(machine.provider, machine.config, machine.env).to_hash
            end

            private

            def check_ssh_key_permissions
              ssh_info[:private_key_path].each do |path|
                Vagrant::Util::SSH.check_key_permissions(Pathname.new(path))
              end
            end

            def common_connect_opts
              # Build the options we'll use to initiate the connection via Net::SSH
              @common_connect_opts ||= {
                auth_methods:          %w(none publickey hostbased password),
                config:                false,
                forward_agent:         ssh_info[:forward_agent],
                keys:                  ssh_info[:private_key_path],
                keys_only:             true,
                paranoid:              false,
                password:              ssh_info[:password],
                port:                  ssh_info[:port],
                timeout:               15,
                user_known_hosts_file: [],
                verbose:               :debug
              }
            end

            def connection_valid?
              return false unless @connection
              return false if @connection.closed?

              # There is a chance that the socket is closed despite us checking
              # 'closed?' above. To test this we need to send data through the
              # socket.
              begin
                @connection.exec!('')
                true
              rescue StandardError => e
                logger.info('Connection errored, not re-using. Will reconnect.')
                logger.debug(e.inspect)
                @connection = nil
                false
              end
            end

            def uses_password?
              !!ssh_info[:password]
            end

            def validate_ssh_info!
              raise Vagrant::Errors::SSHNotReady if ssh_info.nil?
            end
          end
        end
      end
    end
  end
end
