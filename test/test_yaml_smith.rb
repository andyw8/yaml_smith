# frozen_string_literal: true

require 'test_helper'
require 'open3'
require 'rbconfig'
require 'tmpdir'

class TestYamlSmith < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::YamlSmith::VERSION
  end

  def test_adds_a_yaml_value_to_a_top_level_mapping
    with_yaml("# Settings\nname: app\n") do |path|
      YamlSmith::AddKey.call(path, 'timeout', '30')

      assert_equal "---\n# Settings\nname: app\ntimeout: 30\n", File.read(path)
    end
  end

  def test_parses_non_string_values_as_yaml
    with_yaml("enabled: false\n") do |path|
      YamlSmith::AddKey.call(path, 'ports', '[3000, 3001]')

      assert_equal "---\nenabled: false\nports: [3000, 3001]\n", File.read(path)
    end
  end

  def test_rejects_an_existing_key_without_changing_the_file
    with_yaml("name: app\n") do |path|
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::AddKey.call(path, 'name', 'other')
      end

      assert_equal 'key already exists: name', error.message
      assert_equal "name: app\n", File.read(path)
    end
  end

  def test_rejects_a_non_mapping_document
    with_yaml("- app\n") do |path|
      error = assert_raises(YamlSmith::Error) do
        YamlSmith::AddKey.call(path, 'name', 'app')
      end

      assert_equal 'YAML document must contain a top-level mapping', error.message
    end
  end

  def test_reports_invalid_yaml
    with_yaml("name: [app\n") do |path|
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
    with_yaml("name: app\n") do |path|
      _, stderr, status = Open3.capture3(
        RbConfig.ruby, '-Ilib', 'exe/yaml-smith', 'add', path, 'timeout', '30'
      )

      assert_predicate status, :success?, stderr
      assert_equal "---\nname: app\ntimeout: 30\n", File.read(path)
    end
  end

  private

  def with_yaml(contents)
    Dir.mktmpdir do |directory|
      path = File.join(directory, 'config.yml')
      File.write(path, contents)
      yield path
    end
  end
end
