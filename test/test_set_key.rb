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

  def test_set_a_nested_value_in_an_array
    with_yaml(<<~YAML) do |path|
      services:
        - type: web
          name: rails
    YAML
      YamlSmith::SetKey.call(path, 'services.0.name', 'rails_foo')

      assert_equal <<~YAML, File.read(path)
        ---
        services:
        - type: web
          name: rails_foo
      YAML
    end
  end

  def test_set_a_nested_value_with_bracket_notation
    with_yaml(<<~YAML) do |path|
      services:
        - type: web
          name: rails
    YAML
      YamlSmith::SetKey.call(path, 'services[0].name', 'rails_foo')

      assert_equal <<~YAML, File.read(path)
        ---
        services:
        - type: web
          name: rails_foo
      YAML
    end
  end

  def test_set_rejects_a_missing_nested_path
    with_yaml(<<~YAML) do |path|
      services:
        - type: web
    YAML
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::SetKey.call(path, 'services.5.name', 'x')
      end

      assert_equal 'segment does not exist: 5', error.message
    end
  end
end
