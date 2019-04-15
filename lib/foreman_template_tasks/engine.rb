# frozen_string_literal: true

require 'dynflow'
require 'foreman-tasks'

module ForemanTemplateTasks
  class Engine < ::Rails::Engine
    engine_name 'foreman_template_tasks'

    config.autoload_paths += Dir["#{config.root}/app/lib"]

    initializer 'foreman_template_tasks.register_paths' do |_app|
      ::ForemanTasks.dynflow.config.eager_load_paths.concat(%W[#{ForemanTemplateTasks::Engine.root}/app/lib/actions])
    end

    initializer 'foreman_template_tasks.register_plugin', before: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_template_tasks do
        requires_foreman '>= 1.19'
      end
    end

    initializer 'foreman_template_tasks.dynflow_world', before: 'foreman_tasks.initialize_dynflow' do |_app|
      ::ForemanTasks.dynflow.require!
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      begin
        # ::
      rescue StandardError => e
        Rails.logger.warn "ForemanTemplateTasks: skipping engine hook (#{e})"
      end
    end
  end
end
