module Vagrant
  module Smartos
    module Zones
      module Util
        class Downloader
          attr_reader :url, :utility

          GET_PARAMS = {
            'wget' => '-qO',
            'curl' => '--silent -o'
          }

          READ_PARAMS = {
            'wget' => '-qO-',
            'curl' => '--silent'
          }

          def initialize(url)
            @url = url
            @utility = download_utility
          end

          def self.get(url, path)
            new(url).get(path)
          end

          def get(path)
            `#{utility} #{url} #{GET_PARAMS[utility]} #{path}`
          end

          def read
            `#{utility} #{url} #{READ_PARAMS[utility]}`
          end

          private

          def download_utility
            if system('which wget >/dev/null')
              'wget'
            else
              'curl'
            end
          end
        end
      end
    end
  end
end
