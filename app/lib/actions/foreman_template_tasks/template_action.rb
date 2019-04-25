# frozen_string_literal: true

module Actions
  module ForemanTemplateTasks
    class TemplateAction < Actions::Base
      include Actions::RecurringAction

      middleware.use Actions::Middleware::KeepCurrentUser

      def plan(template_params = {})
        input.update task_params: template_params
        plan_self
      end

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
                 location = self.class == TemplateImportAction ? 'local' : 'remote'
                 "no changes to #{location} templates"
               end

        out += if exceptions.any?
                 ", #{output[:results].reject { |r| r[:exception].nil? }.count} templates skipped;\n- " + exceptions.join("\n- ")
               else
                 '.'
               end

        if changes.any?
          out += "\n\nTemplates changed:\n- " + changes.map { |ch| "#{ch[:type].camel_case} | #{ch[:name]}" }.join("\n- ")
        end

        out
      end

      def humanized_action
        raise NotImplementedError
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
