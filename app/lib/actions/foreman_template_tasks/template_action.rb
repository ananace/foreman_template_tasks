# frozen_string_literal: true

module Actions
  module ForemanTemplateTasks
    class TemplateAction < Actions::Base
      middleware.use Actions::Middleware::KeepCurrentUser

      def plan(template_params = {})
        input.update task_params: template_params
        plan_self
      end

      def humanized_output
        return unless output[:results]

        exceptions = output[:results]
                     .reject { |r| r[:exception].nil? }
                     .group_by { |r| [r[:type], r[:additional_errors] || r[:exception]] }
                     .map do |k, v|
          "#{v.size} templates#{k.first.nil? ? '' : " of type #{k.first}"} skipped: #{k.last}"
        end

        out = "#{humanized_action} finished, #{output[:results].select { |r| r[:exception].nil? }.count} templates handled"
        if exceptions.empty?
          out += '.'
        else
          out += ", #{output[:results].reject { |r| r[:exception].nil? }.count} skipped;"
          out += "\n\n" + exceptions.join("\n")
        end
        out
      end

      def humanized_action
        ''
      end

      def task_output
        (output[:results] || []).map do |r|
          {
            name: r[:name],
            type: r[:type],
            changed: r[:changed],
            imported: r[:imported],
            error: r[:additional_errors] || r[:exception]
          }
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
