# frozen_string_literal: true

require 'test_helper'
require 'open3'
require 'rbconfig'

class TestAddKey < Minitest::Test
  include YamlFileTestHelper

  def test_adds_a_yaml_value_to_a_top_level_mapping
    with_yaml(<<~YAML) do |path|
      # Settings
      name: app
    YAML
      YamlSmith::AddKey.call(path, 'timeout', '30')

      assert_equal <<~YAML, File.read(path)
        ---
        # Settings
        name: app
        timeout: 30
      YAML
    end
  end

  def test_parses_non_string_values_as_yaml
    with_yaml(<<~YAML) do |path|
      enabled: false
    YAML
      YamlSmith::AddKey.call(path, 'ports', '[3000, 3001]')

      assert_equal <<~YAML, File.read(path)
        ---
        enabled: false
        ports: [3000, 3001]
      YAML
    end
  end

  def test_rejects_an_existing_key_without_changing_the_file
    with_yaml(<<~YAML) do |path|
      name: app
    YAML
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::AddKey.call(path, 'name', 'other')
      end

      assert_equal 'key already exists: name', error.message
      assert_equal <<~YAML, File.read(path)
        name: app
      YAML
    end
  end

  def test_rejects_a_non_mapping_document
    with_yaml(<<~YAML) do |path|
      - app
    YAML
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::AddKey.call(path, 'name', 'app')
      end

      assert_equal 'YAML document must contain a top-level mapping', error.message
    end
  end

  def test_reports_invalid_yaml
    with_yaml(<<~YAML) do |path|
      name: [app
    YAML
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::AddKey.call(path, 'timeout', '30')
      end

      assert_match(/invalid YAML:/, error.message)
    end
  end

  def test_reports_a_missing_file
    error = assert_raises(YamlSmith::Error) do
      YamlSmith::AddKey.call('missing.yml', 'name', 'app')
    end

    assert_match(/No such file or directory/, error.message)
  end

  def test_command_adds_a_key
    with_yaml(<<~YAML) do |path|
      name: app
    YAML
      _, stderr, status = Open3.capture3(
        RbConfig.ruby, '-Ilib', 'exe/yaml-smith', 'add', path, 'timeout', '30'
      )

      assert_predicate status, :success?, stderr
      assert_equal <<~YAML, File.read(path)
        ---
        name: app
        timeout: 30
      YAML
    end
  end
end
