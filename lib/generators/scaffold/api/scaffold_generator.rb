# frozen_string_literal: true

require "rails/generators"
module Generators
  module Scaffold
    module Api
      class ScaffoldGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        def generate_components
          case scaffold_component
          when "model"
            generate_model
          when "controller"
            generate_controller
          when "migration"
            generate_migration
          when "serializer"
            generate_serializer
          else
            generate_all_components
          end
        end

        private

        def scaffold_component
          options[:only].to_s.strip.downcase.presence || "all"
        end

        def generate_model
          invoke "scaffold:api:model", [ name ] + args
        end

        def generate_controller
          invoke "scaffold:api:controller", [ name ] + args
        end

        def generate_migration
          invoke "scaffold:api:migration", [ name ]
        end

        def generate_serializer
          invoke "scaffold:api:serializer", [ name ]
        end

        def generate_all_components
          generate_model
          generate_controller
          generate_migration
          generate_serializer
        end
      end
    end
  end
end
