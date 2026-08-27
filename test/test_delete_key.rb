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

  def test_deletes_matching_keys_recursively
    yaml = "services:\n  - type: web\n    envVars:\n      - WEB_CONCURRENCY: \"0\"\n      - RAILS_MASTER_KEY: false\n"
    with_yaml(yaml) do |path|
      YamlSmith::DeleteKey.call(path, 'WEB_CONCURRENCY')

      expected = "---\nservices:\n- type: web\n  envVars:\n  - RAILS_MASTER_KEY: false\n"
      assert_equal expected, File.read(path)
    end
  end
end
