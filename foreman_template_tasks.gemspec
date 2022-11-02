# frozen_string_literal: true

require File.expand_path('lib/foreman_template_tasks/version', __dir__)

Gem::Specification.new do |spec|
  spec.name          = 'foreman_template_tasks'
  spec.version       = ForemanTemplateTasks::VERSION
  spec.authors       = ['Alexander Olofsson']
  spec.email         = ['alexander.olofsson@liu.se']

  spec.summary       = 'Foreman plug-in to automatically sync templates'
  spec.homepage      = 'https://github.com/ananace/foreman_template_tasks'
  spec.license       = 'GPL-3.0'

  spec.files         = Dir['{app,lib}/**/*'] + %w[LICENSE Rakefile README.md]

  spec.add_runtime_dependency 'foreman-tasks'
  spec.add_runtime_dependency 'foreman_templates'

  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rails'
end
