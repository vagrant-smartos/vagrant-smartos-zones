require 'digest/md5'

module Vagrant
  module Smartos
    module Zones
      module Util
        class Checksum
          attr_reader :path, :checksum

          def initialize(path, checksum)
            @path = path
            @checksum = checksum
          end

          def valid?
            Digest::MD5.file(path) == checksum
          end
        end
      end
    end
  end
end
