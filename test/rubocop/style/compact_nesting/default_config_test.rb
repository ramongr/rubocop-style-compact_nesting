# frozen_string_literal: true

require_relative '../../../test_helper'

require 'yaml'

# Regression guard for the plugin's bundled default config. These assertions
# pin the behaviour documented in the README and CHANGELOG: the plugin's
# cop is enabled, and Style/ClassAndModuleChildren (which enforces the
# opposite layout) is disabled.
class DefaultConfigTest < Test::Unit::TestCase
  CONFIG_PATH = File.expand_path('../../../../config/default.yml', __dir__)

  def setup
    @config = YAML.load_file(CONFIG_PATH)
  end

  def test_compact_module_nesting_is_enabled
    cop = @config.fetch('Style/CompactModuleNesting')
    assert_equal(true, cop.fetch('Enabled'))
  end

  def test_class_and_module_children_is_disabled
    cop = @config.fetch('Style/ClassAndModuleChildren')
    assert_equal(false, cop.fetch('Enabled'))
  end
end
