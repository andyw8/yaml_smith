# frozen_string_literal: true

require 'test_helper'

class TestSetKey < Minitest::Test
  include YamlFileTestHelper

  def test_sets_an_existing_value
    with_yaml("# Settings\ntimeout: 30\nname: app\n") do |path|
      YamlSmith::SetKey.call(path, 'timeout', '60')

      assert_equal "---\n# Settings\ntimeout: 60\n\nname: app\n", File.read(path)
    end
  end

  def test_set_adds_a_missing_value
    with_yaml("name: app\n") do |path|
      YamlSmith::SetKey.call(path, 'timeout', '60')

      assert_equal "---\nname: app\ntimeout: 60\n", File.read(path)
    end
  end
end
