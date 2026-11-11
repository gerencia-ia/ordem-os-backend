# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class ControllerGenerator < Base
      argument :attributes, type: :array, default: []

      def create_controller_file
        ensure_api_version_components!(controllers: true)
        template "api/scaffold_controller/controller.rb.tt", controller_file_path
      end
    end
  end
end
