require 'spec_helper'
require 'pathname'
require 'vagrant/smartos/zones/models/network'

RSpec.describe Vagrant::Smartos::Zones::Models::Network do
  subject(:network) { described_class.new(env) }

  let(:env) { default_env }
  let(:default_env) { { home_path: pwd.join(home_path) } }
  let(:pwd) { Pathname.new(ENV['PWD']) }
  let(:home_path) { 'spec/fixtures/config/default' }

  describe 'network' do
    it 'defaults to 172.16.0.0/24' do
      expect(network.network).to eq('172.16.0.0/24')
    end

    describe 'with a network specified in the plugin configuration' do
      let(:home_path) { 'spec/fixtures/config/network' }

      it 'uses the value' do
        expect(network.network).to eq('10.16.0.0/16')
      end
    end
  end

  describe 'zone_network' do
    it 'is a CIDR of the network' do
      expect(network.zone_network).to eq('172.16.0.0/24')
    end
  end

  describe 'gz_addr' do
    it 'is a CIDR of the first IP on the network' do
      expect(network.gz_addr).to eq('172.16.0.1/24')
    end
  end

  describe 'gz_stub_ip' do
    it 'is the first IP on the network' do
      expect(network.gz_stub_ip).to eq('172.16.0.1')
    end
  end

  describe 'zone_ip' do
    it 'is the second IP on the network' do
      expect(network.zone_ip).to eq('172.16.0.2')
    end
  end
end
