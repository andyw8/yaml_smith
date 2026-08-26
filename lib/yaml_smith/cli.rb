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
    USAGE = 'Usage: yaml-smith COMMAND FILE KEY [VALUE]'

    def self.call(arguments)
      new(arguments).call
    end

    def initialize(arguments)
      @arguments = arguments
    end

    def call
      command = COMMANDS[@arguments.first]
      return usage unless valid_arguments?(command)

      command.call(*command_arguments)
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
      @arguments.drop(1)
    end

    def usage
      warn USAGE
      1
    end
  end
end
