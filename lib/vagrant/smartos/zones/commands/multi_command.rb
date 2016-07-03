module Vagrant
  module Smartos
    module Zones
      module Command
        # Requires
        #
        # Define a COMMANDS constant, which is an array of method names:
        #
        #   COMMANDS = %w(subcommand other_subcommand)
        #
        # Define an OPTION_PARSER constant, which is an instance of an
        # OptionParser
        #
        module MultiCommand
          # Automatically called by Vagrant when running a command
          def execute
            process_subcommand
          end

          # Sends parsed argv to an instance method that maps to the
          # subcommand name. If flags are passed to the option parser,
          # they will be included in argv as a trailing hash.
          def process_subcommand
            @options = {}
            args = parse_options(option_parser)
            exit unless args

            command = args.shift
            command_method = subcommands.find { |c| c == command }

            unless command_method
              @env.ui.warn option_parser.to_s, prefix: false
              exit 1
            end

            args << @options unless @options.empty?
            send command, *args
          end

          def fail_options!
            @env.ui.warn option_parser.to_s, prefix: false
            exit 1
          end

          def option_parser
            @option_parser ||= self.class.const_get('OPTION_PARSER')
          end

          def subcommands
            self.class.const_get('COMMANDS')
          end
        end
      end
    end
  end
end
