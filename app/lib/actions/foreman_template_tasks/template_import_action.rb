# frozen_string_literal: true

module Actions
  module ForemanTemplateTasks
    class TemplateImportAction < TemplateAction

      def run
        importer = ForemanTemplates::TemplateImporter.new(input[:task_params])
        output[:results] = importer.import![:results].map(&:to_h)
      end

      def humanized_action
        'Import'
      end
    end
  end
end
