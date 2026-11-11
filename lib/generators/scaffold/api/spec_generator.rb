# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class SpecGenerator < Base
      argument :attributes, type: :array, default: []

      class_option :skip_model, type: :boolean, default: false, desc: "Ignora a geração do spec de model"
      class_option :skip_request, type: :boolean, default: false, desc: "Ignora a geração do spec de request"
      class_option :skip_swagger, type: :boolean, default: false, desc: "Ignora a geração do spec Swagger/Rswag"

      def create_model_spec
        return if options[:skip_model]

        template "rspec/model/model_spec.rb.tt", model_spec_file_path
      end

      def create_request_spec
        return if options[:skip_request]

        template "api/spec/request_spec.rb.tt", request_spec_file_path
      end

      def create_swagger_spec
        return if options[:skip_swagger]

        ensure_api_version_components!(swagger: true)
        template "rswag/integration/swagger_spec.rb.tt", swagger_spec_file_path
      end
    end
  end
end
