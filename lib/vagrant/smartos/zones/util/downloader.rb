module Vagrant
  module Smartos
    module Zones
      module Util
        class Downloader
          def self.get(url, path)
            new.get(url, path)
          end

          def get(url, path)
            self.send(download_utility, url, path)
          end

          private

          def download_utility
            if `which wget`
              'wget'
            else
              'curl'
            end
          end

          def wget(url, path)
            `wget #{url} -O #{path}`
          end

          def curl(url, path)
            `curl #{url} -o #{path}`
          end
        end
      end
    end
  end
end
