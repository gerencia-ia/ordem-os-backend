# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class ScaffoldGenerator < Base
      class_option :only,
                   type: :string,
                   desc: "Gera apenas um componente específico (model, migration, controller, serializer, policy, route, spec)"
      class_option :skip_routes, type: :boolean, default: false, desc: "Não altera config/routes.rb"
      class_option :skip_model, type: :boolean, default: false, desc: "Ignora model e migration"
      class_option :skip_migration, type: :boolean, default: false, desc: "Ignora migration"
      class_option :skip_controller, type: :boolean, default: false, desc: "Ignora controller"
      class_option :skip_serializer, type: :boolean, default: false, desc: "Ignora serializer"
      class_option :skip_policy, type: :boolean, default: false, desc: "Ignora policy"
      class_option :skip_spec, type: :boolean, default: false, desc: "Ignora specs"

      def generate_components
        case scaffold_component
        when "all"
          generate_all_components
        when "model"
          generate_model
        when "migration"
          generate_migration
        when "controller"
          generate_controller
        when "serializer"
          generate_serializer
        when "policy"
          generate_policy
        when "route", "routes"
          generate_route
        when "spec", "specs"
          generate_spec
        else
          raise Thor::Error, "Valor inválido para --only: #{options[:only].inspect}. Opções: model, migration, controller, serializer, policy, route, spec."
        end
      end

      private

      def scaffold_component
        options[:only].to_s.strip.downcase.presence || "all"
      end

      def generate_model
        return if options[:skip_model]

        invoke "scaffold:api:model", [ name ] + args, forwarded_api_options
      end

      def generate_migration
        return if options[:skip_model] || options[:skip_migration]

        invoke "scaffold:api:migration", [ name ] + args, forwarded_api_options
      end

      def generate_controller
        return if options[:skip_controller]

        invoke "scaffold:api:controller", [ name ] + args, forwarded_api_options
      end

      def generate_serializer
        return if options[:skip_serializer]

        invoke "scaffold:api:serializer", [ name ] + args, forwarded_api_options
      end

      def generate_policy
        return if options[:skip_policy]

        invoke "scaffold:api:policy", [ name ], forwarded_api_options
      end

      def generate_route
        return if options[:skip_routes]

        invoke "scaffold:api:route", [ name ], forwarded_api_options
      end

      def generate_spec
        return if options[:skip_spec]

        spec_opts = forwarded_api_options.merge(
          "skip_model" => ActiveModel::Type::Boolean.new.cast(options[:skip_model])
        )
        invoke "scaffold:api:spec", [ name ] + args, spec_opts
      end

      def generate_all_components
        ensure_api_version_components!(
          controllers: !options[:skip_controller],
          routes: !options[:skip_routes],
          swagger: !options[:skip_spec]
        )
        generate_model
        generate_migration
        generate_controller
        generate_serializer
        generate_policy
        generate_route
        generate_spec
      end
    end
  end
end
