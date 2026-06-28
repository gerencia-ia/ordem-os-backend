# frozen_string_literal: true

require "rails/generators"
module Generators
  module Scaffold
    module Api
      class ModelGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        argument :attributes, type: :array, default: []

        def create_model_file
          # Passando os atributos para o template
          assign_attributes = attributes.map { |attr| { name: attr.name, type: attr.type } }
          template "model.rb.tt", File.join("app/models", class_path, "#{file_name}.rb"), assign_attributes: assign_attributes
        end
      end
    end
  end
end
