# frozen_string_literal: true

require "rails/generators"

module Scaffold
  module Api
    class Base < Rails::Generators::NamedBase
      source_paths << File.expand_path("../../../templates", __dir__)

      class_option :api_version,
                   type: :string,
                   desc: "Versão da API (ex: v1, v2). Padrão: config.x.api_version"
      class_option :versioned_serializer,
                   type: :boolean,
                   default: false,
                   desc: "Gera serializer isolado no namespace da versão da API"
      class_option :force_plural,
                   type: :boolean,
                   default: false,
                   desc: "Mantém o nome do recurso no plural sem singularizar"

      private

      def api_version
        @api_version ||= resolve_api_version
      end

      def resolve_api_version
        option_version = normalize_api_version(options[:api_version]) if options[:api_version].present?
        prefix_version = prefixed_api_version

        if option_version && prefix_version && option_version != prefix_version
          raise Thor::Error,
                "Versão conflitante: prefixo '#{prefix_version}' diverge de --api-version='#{options[:api_version]}'."
        end

        option_version || prefix_version || configured_default_api_version
      end

      def normalize_api_version(raw)
        value = raw.to_s.strip.downcase
        value = "v#{value}" if value.match?(/\A\d+\z/)
        unless value.match?(/\Av\d+\z/)
          raise Thor::Error, "Versão da API inválida: #{raw.inspect}. Use o formato v1, v2, etc."
        end

        value
      end

      def configured_default_api_version
        raw = Rails.application.config.x.api_version.presence || "v1"
        normalize_api_version(raw)
      end

      def prefixed_api_version
        return unless class_path.size >= 2 && class_path[0] == "api" && class_path[1].match?(/\Av\d+\z/)

        class_path[1]
      end

      def api_version_module
        @api_version_module ||= api_version.camelize
      end

      def api_class_path
        @api_class_path ||= begin
          parts = class_path.dup
          if parts.size >= 2 && parts[0] == "api" && parts[1].match?(/\Av\d+\z/)
            parts.drop(2)
          elsif parts.first == "api"
            parts.drop(1)
          else
            parts
          end
        end
      end

      def normalized_singular_name
        @normalized_singular_name ||= options[:force_plural] ? file_name : file_name.singularize
      end

      def normalized_plural_name
        @normalized_plural_name ||= normalized_singular_name.pluralize
      end

      def model_class_name
        @model_class_name ||= (api_class_path + [ normalized_singular_name ]).join("/").camelize
      end

      def controller_class_name
        @controller_class_name ||= (api_class_path + [ normalized_plural_name ]).join("/").camelize
      end

      def singular_resource_name
        @singular_resource_name ||= (api_class_path + [ normalized_singular_name ]).join("_")
      end

      def plural_resource_name
        @plural_resource_name ||= (api_class_path + [ normalized_plural_name ]).join("_")
      end

      def model_file_path
        File.join(*api_class_path, normalized_singular_name)
      end

      def controller_file_path
        File.join("app/controllers/api", api_version, *api_class_path, "#{normalized_plural_name}_controller.rb")
      end

      def versioned_serializer?
        ActiveModel::Type::Boolean.new.cast(options[:versioned_serializer])
      end

      def serializer_namespace_modules
        @serializer_namespace_modules ||= begin
          mods = versioned_serializer? ? [ "Api", api_version_module ] : []
          mods + api_class_path.map(&:camelize)
        end
      end

      def serializer_leaf_class
        @serializer_leaf_class ||= "#{normalized_singular_name.camelize}Serializer"
      end

      def serializer_file_path
        base_parts = versioned_serializer? ? [ "app/serializers/api", api_version ] : [ "app/serializers" ]
        File.join(*base_parts, *api_class_path, "#{normalized_singular_name}_serializer.rb")
      end

      def policy_file_path
        File.join("app/policies", *api_class_path, "#{normalized_singular_name}_policy.rb")
      end

      def model_spec_file_path
        File.join("spec/models", *api_class_path, "#{normalized_singular_name}_spec.rb")
      end

      def request_spec_file_path
        File.join("spec/requests/api", api_version, *api_class_path, "#{normalized_plural_name}_spec.rb")
      end

      def swagger_spec_file_path
        File.join("spec/integration/api", api_version, *api_class_path, "#{normalized_plural_name}_spec.rb")
      end

      def api_route_path
        "/api/#{api_version}/#{(api_class_path + [ normalized_plural_name ]).join('/')}"
      end

      def ensure_api_version_components!(controllers: false, routes: false, swagger: false)
        return unless behavior == :invoke

        invoke "scaffold:api:version",
               [ api_version ],
               runtime_invoke_options.merge(controllers: controllers, routes: routes, swagger: swagger)
      end

      def forwarded_api_options
        runtime_invoke_options.merge(
          "api_version" => api_version,
          "versioned_serializer" => versioned_serializer?,
          "force_plural" => options[:force_plural]
        ).compact
      end

      def runtime_invoke_options
        {
          "pretend" => options[:pretend],
          "force" => options[:force],
          "skip" => options[:skip],
          "quiet" => options[:quiet]
        }.compact
      end

      def permitted_params_symbols
        attributes.flat_map do |attr|
          if attr.polymorphic?
            [ ":#{attr.name}_id", ":#{attr.name}_type" ]
          elsif attr.password_digest?
            [ ":password", ":password_confirmation" ]
          else
            [ ":#{attr.column_name}" ]
          end
        end
      end

      def sample_value_literal(attr, updated: false)
        case attr.type
        when :integer, :bigint
          updated ? "2" : "1"
        when :float, :decimal
          updated ? "20.5" : "10.5"
        when :boolean
          updated ? "false" : "true"
        when :date
          updated ? '"2026-02-20"' : '"2026-01-15"'
        when :datetime, :timestamp
          updated ? '"2026-02-20T14:00:00Z"' : '"2026-01-15T10:00:00Z"'
        else
          updated ? %("Exemplo #{attr.name} atualizado") : %("Exemplo #{attr.name}")
        end
      end

      def openapi_property_literal(attr)
        if attr.reference? || %i[integer bigint].include?(attr.type)
          "{ type: :integer, example: 1 }"
        elsif attr.type == :float
          "{ type: :number, example: 10.5 }"
        elsif attr.type == :decimal
          '{ type: :string, example: "10.50" }'
        elsif attr.type == :boolean
          "{ type: :boolean, example: true }"
        elsif attr.type == :date
          '{ type: :string, format: :date, example: "2026-01-15" }'
        elsif %i[datetime timestamp].include?(attr.type)
          "{ type: :string, format: :date_time }"
        else
          %({ type: :string, example: "Exemplo #{attr.name}" })
        end
      end
    end
  end
end
