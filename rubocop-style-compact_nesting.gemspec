# frozen_string_literal: true

require_relative 'lib/rubocop/style/compact_nesting/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-style-compact_nesting'
  spec.version = RuboCop::Style::CompactNesting::VERSION
  spec.authors = ['Ramon Rodrigues']
  spec.email = ['cerberus.ramon@gmail.com']

  spec.summary = 'RuboCop cop enforcing compact outer module nesting with a separately nested innermost class/module.'
  spec.description = <<~DESC
    A RuboCop plugin providing Style/CompactModuleNesting, which enforces a
    hybrid module/class nesting style: all namespace segments collapsed onto a
    single `module A::B::C` line, with the innermost class or module nested
    separately inside it.
  DESC
  spec.homepage = 'https://github.com/ramongr/rubocop-style-compact_nesting'
  spec.license = 'MIT'
  spec.required_ruby_version = '>  3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::Style::CompactNesting::Plugin'

  spec.files = Dir[
    'lib/**/*',
    'config/**/*',
    'LICENSE.txt',
    'README.md',
    'CHANGELOG.md'
  ]
  spec.require_paths = ['lib']

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '>= 1.72', '< 2.0'
end
