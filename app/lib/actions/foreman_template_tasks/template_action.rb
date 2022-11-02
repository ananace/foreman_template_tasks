# frozen_string_literal: true

module Actions
  module ForemanTemplateTasks
    class TemplateAction < Actions::Base
      include Actions::RecurringAction

      middleware.use Actions::Middleware::KeepCurrentUser

      def delay(delay_options, context: nil, **task_params)
        task_params = task_params.compact
        input.update context: context
        input.update task_params: task_params

        super delay_options, { context: context, task_params: task_params }
      end

      # Rails passes hashes with keys as string by default
      def plan(args = {})
        _plan(args.deep_symbolize_keys)
      end

      def _plan(context: nil, **task_params)
        # Apparently this can happen?
        task_params = task_params[:task_params] if task_params.key? :task_params

        input.update context: context
        input.update task_params: task_params

        plan_self
      end

      # rubocop:disable Metrics/MethodLength
      def humanized_output
        return unless output[:results]

        changes = output[:results]
                  .select { |r| (r[:imported] || r[:exported]) && r[:changed] }

        exceptions = output[:results]
                     .reject { |r| r[:exception].nil? }
                     .group_by { |r| [r[:type], r[:additional_errors] || r[:exception]] }
                     .map do |k, v|
          "#{v.size} templates#{k.first.nil? ? '' : " of type #{k.first}"} skipped because: #{k.last}"
        end

        out = "#{humanized_action} finished, "
        out += if changes.any?
                 "#{changes.count} templates changed"
               else
                 location = is_a?(TemplateImportAction) ? 'local' : 'remote'
                 "no changes to #{location} templates"
               end

        out += if exceptions.any?
                 ", #{output[:results].count { |r| !r[:exception].nil? }} templates skipped;\n- #{exceptions.join("\n- ")}" # rubocop:disable Layout/LineLength
               else
                 '.'
               end

        if changes.any?
          out += "\n\nTemplates changed:\n- #{changes.map { |ch| "#{ch[:type].camelcase} | #{ch[:name]}" }.join("\n- ")}" # rubocop:disable Layout/LineLength
        end

        out
      end
      # rubocop:enable Metrics/MethodLength

      def humanized_action
        raise NotImplementedError
      end

      def humanized_name
        format N_('%<action>s Foreman Templates%<context>s'),
               action: humanized_action,
               context: input[:context] ? " (#{input[:context]})" : ''
      end

      def task_output
        (output[:results] || []).map do |r|
          {
            name: r[:name],
            type: r[:type],
            changed: r[:changed],
            imported: r[:imported],
            exported: r[:exported],
            error: r[:additional_errors] || r[:exception]
          }.compact
        end
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Skip
      end

      def self.cleanup_after
        '1d'
      end
    end
  end
end
