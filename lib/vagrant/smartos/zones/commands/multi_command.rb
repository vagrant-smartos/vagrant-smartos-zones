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
          def execute
            process_subcommand
          end

          def process_subcommand
            args = parse_options(option_parser)
            exit unless args

            command = args.shift
            command_method = subcommands.find { |c| c == command }

            unless command_method
              ui.warn option_parser.to_s, prefix: false
              exit 1
            end

            send command, *args
          end

          def fail_options!
            ui.warn option_parser.to_s, prefix: false
            exit 1
          end

          def option_parser
            self.class.const_get('OPTION_PARSER')
          end

          def subcommands
            self.class.const_get('COMMANDS')
          end
        end
      end
    end
  end
end
