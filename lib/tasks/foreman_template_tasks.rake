# frozen_string_literal: true

require 'pp'

namespace :template_tasks do # rubocop:disable Metrics/BlockLength
  desc 'Start a template import according to settings'
  task import: [:environment, 'dynflow:client'] do
    User.current = User.anonymous_admin
    context = ENV['context']

    r = ForemanTasks.delay Actions::ForemanTemplateTasks::TemplateImportAction,
                           { start_at: Time.zone.now },
                           {
                             context: context,
                             repo: ENV['repo'],
                             branch: ENV['branch'],
                             prefix: ENV['prefix'],
                             dirname: ENV['dirname'],
                             filter: ENV['filter'],
                             associate: ENV['associate'],
                             lock: ENV['lock']
                           }.compact

    url = Rails.application.routes.url_helpers.foreman_tasks_task_url(r, host: SETTINGS[:fqdn])
    puts "Task running at #{url}"
    pp r
  end

  desc 'Start a template export according to settings'
  task export: [:environment, 'dynflow:client'] do
    User.current = User.anonymous_admin
    context = ENV['context']

    r = ForemanTasks.delay Actions::ForemanTemplateTasks::TemplateExportAction,
                           { start_at: Time.zone.now },
                           {
                             context: context,
                             repo: ENV['repo'],
                             branch: ENV['branch'],
                             prefix: ENV['prefix'],
                             dirname: ENV['dirname'],
                             filter: ENV['filter'],
                             metadata_export_mode: ENV['metadata_export_mode']
                           }.compact

    url = Rails.application.routes.url_helpers.foreman_tasks_task_url(r, host: SETTINGS[:fqdn])
    puts "Task running at #{url}"
    pp r
  end

  namespace :import do
    desc 'Schedule a recurring template import'
    task schedule_recurring: [:environment, 'dynflow:client'] do
      context = ENV['context']
      cronline = ENV['cronline']

      raise 'Need to specify a cronline' unless cronline

      User.current = User.anonymous_admin
      r = ForemanTasks::RecurringLogic.new_from_cronline(cronline)

      r.start Actions::ForemanTemplateTasks::TemplateImportAction,
              {
                context: context,
                repo: ENV['repo'],
                branch: ENV['branch'],
                prefix: ENV['prefix'],
                dirname: ENV['dirname'],
                filter: ENV['filter'],
                associate: ENV['associate'],
                lock: ENV['lock']
              }.compact

      url = Rails.application.routes.url_helpers.foreman_tasks_recurring_logic_url(r, host: SETTINGS[:fqdn])
      puts "Recurring logic created at #{url}"
      pp r
    end
  end

  namespace :export do
    desc 'Schedule a recurring template import'
    task schedule_recurring: [:environment, 'dynflow:client'] do
      context = ENV['context']
      cronline = ENV['cronline']

      raise 'Need to specify a cronline' unless cronline

      User.current = User.anonymous_admin
      r = ForemanTasks::RecurringLogic.new_from_cronline(cronline)

      r.start Actions::ForemanTemplateTasks::TemplateExportAction,
              {
                context: context,
                repo: ENV['repo'],
                branch: ENV['branch'],
                prefix: ENV['prefix'],
                dirname: ENV['dirname'],
                filter: ENV['filter'],
                metadata_export_mode: ENV['metadata_export_mode']
              }.compact

      url = Rails.application.routes.url_helpers.foreman_tasks_recurring_logic_url(r, host: SETTINGS[:fqdn])
      puts "Recurring logic created at #{url}"
      pp r
    end
  end
end
