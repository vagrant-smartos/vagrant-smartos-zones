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
            `#{utility} #{url} #{get_params} #{path}`
          end

          def read
            `#{utility} #{url} #{read_params}`
          end

          private

          def download_utility
            if system('which wget >/dev/null')
              'wget'
            else
              'curl'
            end
          end

          def get_params
            GET_PARAMS[utility]
          end

          def read_params
            READ_PARAMS[utility]
          end
        end
      end
    end
  end
end
