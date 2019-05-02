# frozen_string_literal: true

module Actions
  module ForemanTemplateTasks
    class TemplateExportAction < TemplateAction

      def run
        exporter = ForemanTemplates::TemplateExporter.new(input[:task_params])
        output[:results] = exporter.export![:results].map(&:to_h)
      end

      def humanized_action
        'Export'
      end
    end
  end
end
