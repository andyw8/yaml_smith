# frozen_string_literal: true

require 'test_helper'

class TestDeleteKey < Minitest::Test
  include YamlFileTestHelper

  def test_deletes_a_value
    with_yaml(<<~YAML) do |path|
      # Settings
      timeout: 30
      name: app
    YAML
      YamlSmith::DeleteKey.call(path, 'timeout')

      assert_equal <<~YAML, File.read(path)
        ---
        # Settings
        name: app
      YAML
    end
  end

  def test_delete_rejects_a_missing_key_without_changing_the_file
    with_yaml(<<~YAML) do |path|
      name: app
    YAML
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::DeleteKey.call(path, 'timeout')
      end

      assert_equal 'key does not exist: timeout', error.message
      assert_equal <<~YAML, File.read(path)
        name: app
      YAML
    end
  end

  def test_deletes_matching_keys_recursively
    yaml = <<~YAML
      services:
        - type: web
          envVars:
            - WEB_CONCURRENCY: "0"
            - RAILS_MASTER_KEY: false
    YAML
    with_yaml(yaml) do |path|
      YamlSmith::DeleteKey.call(path, 'WEB_CONCURRENCY')

      expected = <<~YAML
        ---
        services:
        - type: web
          envVars:
          - RAILS_MASTER_KEY: false
      YAML
      assert_equal expected, File.read(path)
    end
  end

  def test_top_level_only_does_not_delete_nested_keys
    yaml = <<~YAML
      timeout: 30
      services:
        - timeout: 60
    YAML
    with_yaml(yaml) do |path|
      YamlSmith::DeleteKey.call(path, 'timeout', top_level_only: true)

      assert_equal <<~YAML, File.read(path)
        ---
        services: []
      YAML
    end
  end
end
