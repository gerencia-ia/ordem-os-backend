# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class ModelGenerator < Base
      argument :attributes, type: :array, default: []

      def create_model_file
        template "active_record/model/model.rb.tt", File.join("app/models", "#{model_file_path}.rb")
      end

      private

      def class_name
        model_class_name
      end
    end
  end
end
