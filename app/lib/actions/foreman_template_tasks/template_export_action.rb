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

      def humanized_name
        _('Export Foreman Templates')
      end
    end
  end
end
