# frozen_string_literal: true

require "rails/generators"

module Scaffold
  class ScaffoldGenerator < Rails::Generators::NamedBase
    class_option :api_version, type: :string, desc: "Versão da API (ex: v1, v2)"
    class_option :versioned_serializer, type: :boolean, default: false, desc: "Gera serializer namespaced na versão da API"
    class_option :only, type: :string, desc: "Gera apenas um componente específico (model, migration, controller, serializer, policy, route, spec)"
    class_option :skip_routes, type: :boolean, default: false, desc: "Não altera config/routes.rb"
    class_option :skip_model, type: :boolean, default: false, desc: "Ignora model e migration"
    class_option :skip_migration, type: :boolean, default: false, desc: "Ignora migration"
    class_option :skip_controller, type: :boolean, default: false, desc: "Ignora controller"
    class_option :skip_serializer, type: :boolean, default: false, desc: "Ignora serializer"
    class_option :skip_policy, type: :boolean, default: false, desc: "Ignora policy"
    class_option :skip_spec, type: :boolean, default: false, desc: "Ignora specs"
    class_option :force_plural, type: :boolean, default: false, desc: "Mantém o nome do recurso no plural sem singularizar"

    def generate_api_scaffold
      invoke "scaffold:api:scaffold", [ name ] + args, options.to_h
    end
  end
end
