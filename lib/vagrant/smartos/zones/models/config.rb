require 'yaml'

module Vagrant
  module Smartos
    module Zones
      module Models
        class Config
          def self.parse_cli(env, *args)
            config(env).parse(args)
          end

          def self.config(env)
            @config ||= new(env).load
          end

          attr_reader :env, :hash

          def initialize(env)
            @env = env
          end

          def parse(args)
            ui.info(hash.inspect) && return if args.empty?
            options = args.pop if args.last.is_a?(Hash)
            if options && options[:delete]
              delete args.shift
            else
              set(*args)
            end
            save
          end

          def delete(name, *_args)
            hash.delete(name)
          end

          def set(name, value)
            hash[name] = value
          end

          def load
            @hash = YAML.load_file(path) if File.exist?(path)
            @hash ||= {}
            self
          end

          def save
            File.open(path, 'w') { |f| f.write(YAML.dump(hash)) }
          end

          private

          def home_path
            env.respond_to?(:home_path) ? env.home_path : env[:home_path]
          end

          def path
            home_path.join('smartos', 'config.yml')
          end

          def ui
            env.respond_to?(:ui) ? env.ui : env[:ui]
          end
        end
      end
    end
  end
end
