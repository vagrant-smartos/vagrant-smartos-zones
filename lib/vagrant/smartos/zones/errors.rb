module Vagrant
  module Smartos
    module Zones
      class Error < StandardError; end
      class SnapshotNotFound < Error; end
      class ZoneNotFound < Error; end
    end
  end
end
