# frozen_string_literal: true

require_relative 'yaml_smith/version'
require 'psych/pure'
require 'tempfile'

module YamlSmith
  class Error < StandardError; end
end

require_relative 'yaml_smith/file_command'
require_relative 'yaml_smith/add_key'
require_relative 'yaml_smith/set_key'
require_relative 'yaml_smith/delete_key'
