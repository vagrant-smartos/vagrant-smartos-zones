require 'spec_helper'

RSpec.describe 'vagrant user' do
  describe group('vagrant') do
    it { should exist }
  end
end
