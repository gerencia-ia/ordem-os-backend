# frozen_string_literal: true

require "rails/generators"

module Serializer
  class SerializerGenerator < Rails::Generators::NamedBase
    class_option :api_version, type: :string, desc: "Versão da API (ex: v1, v2)"
    class_option :versioned_serializer, type: :boolean, default: false, desc: "Gera serializer namespaced na versão da API"
    class_option :force_plural, type: :boolean, default: false, desc: "Mantém o nome do recurso no plural sem singularizar"

    def generate_serializer
      has_version_prefix = class_path.size >= 2 && class_path[0] == "api" && class_path[1].match?(/\Av\d+\z/)
      versioned = options[:versioned_serializer] || has_version_prefix
      opts = options.to_h.merge("versioned_serializer" => versioned)
      invoke "scaffold:api:serializer", [ name ] + args, opts
    end
  end
end
