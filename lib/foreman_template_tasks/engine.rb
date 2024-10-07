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

    initializer 'foreman_template_tasks.register_plugin', before: :finisher_hook do |app|
      app.reloader.to_prepare do
        Foreman::Plugin.register :foreman_template_tasks do
          requires_foreman '>= 3.12'
        end
      end
    end

    initializer 'foreman_template_tasks.dynflow_world', before: 'foreman_tasks.initialize_dynflow' do |_app|
      ::ForemanTasks.dynflow.require!
    end
  end
end
