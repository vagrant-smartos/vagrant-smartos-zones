require 'netaddr'
require 'vagrant/smartos/zones/models/config'

module Vagrant
  module Smartos
    module Zones
      module Models
        class Network
          attr_reader :env

          def initialize(env)
            @env = env
          end

          def network
            plugin_config.hash['network'] || '172.16.0.0/24'
          end

          def zone_network
            [cidr.network, cidr.netmask].join
          end

          def gz_addr
            [gz_stub_ip, cidr.netmask].join
          end

          def gz_stub_ip
            cidr.nth(1).to_s
          end

          def zone_ip
            cidr.nth(2).to_s
          end

          private

          def cidr
            @cidr ||= NetAddr::IPv4Net.parse(network)
          end

          def plugin_config
            @config ||= Models::Config.config(env)
          end
        end
      end
    end
  end
end
