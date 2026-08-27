# frozen_string_literal: true

require 'test_helper'

class TestSetKey < Minitest::Test
  include YamlFileTestHelper

  def test_sets_an_existing_value
    with_yaml(<<~YAML) do |path|
      # Settings
      timeout: 30
      name: app
    YAML
      YamlSmith::SetKey.call(path, 'timeout', '60')

      assert_equal <<~YAML, File.read(path)
        ---
        # Settings
        timeout: 60

        name: app
      YAML
    end
  end

  def test_set_adds_a_missing_value
    with_yaml(<<~YAML) do |path|
      name: app
    YAML
      YamlSmith::SetKey.call(path, 'timeout', '60')

      assert_equal <<~YAML, File.read(path)
        ---
        name: app
        timeout: 60
      YAML
    end
  end
end
