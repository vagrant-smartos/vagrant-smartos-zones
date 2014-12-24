require 'spec_helper'

RSpec.describe 'vagrant user' do
  describe user('vagrant') do
    it { should exist }
  end
end
