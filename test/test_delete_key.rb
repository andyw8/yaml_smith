# frozen_string_literal: true

require 'test_helper'

class TestDeleteKey < Minitest::Test
  include YamlFileTestHelper

  def test_deletes_a_value
    with_yaml("# Settings\ntimeout: 30\nname: app\n") do |path|
      YamlSmith::DeleteKey.call(path, 'timeout')

      assert_equal "---\n# Settings\nname: app\n", File.read(path)
    end
  end

  def test_delete_rejects_a_missing_key_without_changing_the_file
    with_yaml("name: app\n") do |path|
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::DeleteKey.call(path, 'timeout')
      end

      assert_equal 'key does not exist: timeout', error.message
      assert_equal "name: app\n", File.read(path)
    end
  end

  def test_deletes_a_uniquely_matching_nested_key
    with_yaml(<<~YAML) do |path|
      services:
        - name: rails
          envVars:
            - key: WEB_CONCURRENCY
              value: "0"
            - key: RAILS_MASTER_KEY
              sync: false
    YAML
      YamlSmith::DeleteKey.call(path, 'WEB_CONCURRENCY')

      assert_equal <<~YAML, File.read(path)
        ---
        services:
        - name: rails
          envVars:
          - value: "0"
          - key: RAILS_MASTER_KEY
            sync: false
      YAML
    end
  end

  def test_duplicate_nested_keys_fail_without_changing_the_file
    with_yaml(<<~YAML) do |path|
      services:
        - envVars:
            - key: WEB_CONCURRENCY
              value: "0"
            - key: WEB_CONCURRENCY
              value: "1"
    YAML
      original = File.read(path)
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::DeleteKey.call(path, 'WEB_CONCURRENCY')
      end

      assert_equal 'key is not unique: WEB_CONCURRENCY', error.message
      assert_equal original, File.read(path)
    end
  end
end
