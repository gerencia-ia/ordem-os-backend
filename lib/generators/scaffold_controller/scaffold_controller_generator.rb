# frozen_string_literal: true

require "rails/generators"

module ScaffoldController
  class ScaffoldControllerGenerator < Rails::Generators::NamedBase
    class_option :api_version, type: :string, desc: "Versão da API (ex: v1, v2)"
    class_option :versioned_serializer, type: :boolean, default: false, desc: "Gera serializer namespaced na versão da API"
    class_option :skip_routes, type: :boolean, default: false, desc: "Não altera config/routes.rb"
    class_option :force_plural, type: :boolean, default: false, desc: "Mantém o nome do recurso no plural sem singularizar"

    def generate_api_scaffold_controller
      invoke "api:scaffold", [ name ] + args, options.to_h
    end
  end
end
