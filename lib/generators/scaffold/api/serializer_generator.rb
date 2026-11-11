# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class SerializerGenerator < Base
      argument :attributes, type: :array, default: []

      def create_serializer_file
        template "rails/serializer/serializer.rb.erb", serializer_file_path
      end
    end
  end
end
