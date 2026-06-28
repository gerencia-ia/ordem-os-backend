# frozen_string_literal: true

require "rails/generators"
module Generators
  module Scaffold
    module Api
      class ControllerGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        argument :attributes, type: :array, default: []

        def create_controller_file
          # Definir o namespace aqui para incluir Api::V1
          namespace = "Api::V1"
          file_path = File.join("app/controllers", namespace.underscore, "#{file_name.pluralize}_controller.rb")

          # Passando os atributos para o template
          assign_attributes = attributes.map { |attr| { name: attr.name, type: attr.type } }

          # Gerando o arquivo com o namespace correto
          template "controller.rb.tt", file_path, assign_attributes: assign_attributes
        end
      end
    end
  end
end
