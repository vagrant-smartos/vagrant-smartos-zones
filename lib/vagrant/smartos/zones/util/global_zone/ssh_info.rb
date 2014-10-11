module Vagrant
  module Smartos
    module Zones
      module Util
        module GlobalZone
          class SSHInfo < Struct.new(:provider, :config, :env)
            def forward_agent
              config.ssh.forward_agent
            end

            def forward_x11
              config.ssh.forward_x11
            end

            def host
              return config.ssh.host if config.ssh.host
              return ssh_info[:host] if ssh_info[:host]
              config.ssh.default.host
            end

            def password
              config.ssh.password
            end

            def port
              port_forward[2]
            end

            def private_key_paths
              return [] if password

              @paths ||= [].tap do |paths|
                paths << config.ssh.private_key_path
                paths << config.ssh.default.private_key_path
                paths << env.default_private_key_path
              end.compact.map do |path|
                File.expand_path(path, env.root_path)
              end
            end

            def proxy_command
              config.ssh.proxy_command if config.ssh.proxy_command
            end

            def username
              return config.ssh.password if config.ssh.password
              return ssh_info[:username] if ssh_info[:username]
              config.ssh.default.username
            end

            def to_hash
              # From machine#ssh_info, if provider ssh_info is nil,
              # machine is not ready for SSH.
              return nil if ssh_info.nil?

              {
                host: host,
                port: port,
                private_key_path: private_key_paths,
                username: username,
                password: password,
                proxy_command: proxy_command,
                forward_agent: forward_agent,
                forward_x11: forward_x11
              }.delete_if { |_k, v| v.nil? }
            end

            private

            def ssh_info
              @ssh_info ||= provider.ssh_info
            end

            def port_forward
              @port_forward ||= provider.driver.read_forwarded_ports.find do |fw|
                fw[1] == 'gz_ssh'
              end
            end
          end
        end
      end
    end
  end
end
