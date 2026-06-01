# frozen_string_literal: true

require 'test/unit'
require 'rubocop'
require 'rubocop-style-compact_nesting'

module CopTestHelper
  TARGET_RUBY_VERSION = 3.1

  # Runs the cop against +source+ and returns
  #   [offenses, corrected_source]
  #
  # +offenses+ is an array of RuboCop::Cop::Offense.
  # +corrected_source+ is the result of applying every offered correction; if
  # there are no correctors it equals the original source.
  def lint(source)
    cop = self.class.cop_class.new(cop_config)
    processed = RuboCop::ProcessedSource.new(source, TARGET_RUBY_VERSION)
    commissioner = RuboCop::Cop::Commissioner.new([cop], [], raise_error: true)
    report = commissioner.investigate(processed)
    offenses = report.offenses

    corrected =
      if offenses.any?(&:corrector)
        corrector = RuboCop::Cop::Corrector.new(processed)
        offenses.each { |o| corrector.merge!(o.corrector) if o.corrector }
        result = corrector.process
        result.respond_to?(:source) ? result.source : result
      else
        source
      end

    [offenses, corrected]
  end

  def assert_no_offenses(source)
    offenses, = lint(source)
    assert_equal(
      [],
      offenses.map { |o| "#{o.line}:#{o.column}: #{o.message}" },
      'Expected no offenses'
    )
  end

  def assert_offense(source, message: nil, line: nil)
    offenses, = lint(source)
    refute_empty(offenses, 'Expected at least one offense')
    if message
      assert(
        offenses.any? { |o| o.message == message },
        "Expected an offense with message #{message.inspect}, got: " \
        "#{offenses.map(&:message).inspect}"
      )
    end
    if line
      assert(
        offenses.any? { |o| o.line == line },
        "Expected an offense on line #{line}, got lines: #{offenses.map(&:line).inspect}"
      )
    end
    offenses
  end

  def assert_correction(source, expected)
    _offenses, corrected = lint(source)
    assert_equal(expected, corrected)
  end

  def assert_offense_count(source, count)
    offenses, = lint(source)
    assert_equal(count, offenses.size,
                 "Expected #{count} offenses, got: #{offenses.map(&:message).inspect}")
  end
end

# Base test case wiring up the cop under test.
class CopTestCase < Test::Unit::TestCase
  include CopTestHelper

  class << self
    attr_accessor :cop_class
  end

  # Abstract base: don't run when included by Test::Unit auto-discovery.
  self.test_order = :random

  def self.cop(klass)
    self.cop_class = klass
  end

  def cop_config
    RuboCop::Config.new(
      'AllCops' => { 'TargetRubyVersion' => CopTestHelper::TARGET_RUBY_VERSION },
      self.class.cop_class.cop_name => { 'Enabled' => true }
    )
  end

  # Mark the abstract base as not runnable.
  def self.runnable_methods
    return [] if self == CopTestCase

    super
  end
end
