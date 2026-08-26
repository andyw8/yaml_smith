# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'yaml_smith'

require 'minitest/autorun'
require 'tmpdir'

module YamlFileTestHelper
  def with_yaml(contents)
    Dir.mktmpdir do |directory|
      path = File.join(directory, 'config.yml')
      File.write(path, contents)
      yield path
    end
  end
end
