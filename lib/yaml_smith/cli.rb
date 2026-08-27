# frozen_string_literal: true

require_relative '../yaml_smith'

module YamlSmith
  # Dispatches command-line arguments to a YAML Smith command.
  class CLI
    COMMANDS = {
      'add' => AddKey,
      'set' => SetKey,
      'delete' => DeleteKey
    }.freeze
    USAGE = 'Usage: yaml-smith COMMAND FILE KEY [VALUE] [--top-level-only]'

    def self.call(arguments)
      new(arguments).call
    end

    def initialize(arguments)
      @arguments = arguments
    end

    def call
      command = COMMANDS[@arguments.first]
      return usage unless valid_arguments?(command)

      command.call(*command_arguments, **command_options)
    rescue Error => e
      warn e.message
      1
    end

    private

    def valid_arguments?(command)
      return false unless command

      @arguments.length == (delete_command? ? 3 : 4)
    end

    def delete_command?
      @arguments.first == 'delete'
    end

    def command_arguments
      @arguments.drop(1).reject { |argument| argument == '--top-level-only' }
    end

    def command_options
      return {} unless delete_command?

      { top_level_only: @arguments.include?('--top-level-only') }
    end

    def usage
      warn USAGE
      1
    end
  end
end
