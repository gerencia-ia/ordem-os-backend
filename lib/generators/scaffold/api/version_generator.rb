# frozen_string_literal: true

require "rails/generators"

module Scaffold
  module Api
    class VersionGenerator < Rails::Generators::Base
      source_paths << File.expand_path("../../../templates", __dir__)

      argument :version, type: :string, required: false, desc: "Versão da API (ex: v2)"

      class_option :controllers, type: :boolean, default: true, desc: "Garante os BaseControllers da versão"
      class_option :routes, type: :boolean, default: true, desc: "Garante o namespace em config/routes.rb"
      class_option :swagger, type: :boolean, default: true, desc: "Garante registro no swagger_helper.rb e rswag_ui.rb"

      def provision_version
        return unless behavior == :invoke

        ensure_base_controllers if options[:controllers]
        ensure_routes_namespace if options[:routes]
        ensure_swagger_configuration if options[:swagger]
      end

      private

      def target_version
        @target_version ||= begin
          raw = (version.presence || Rails.application.config.x.api_version.presence || "v1").to_s.strip.downcase
          raw = "v#{raw}" if raw.match?(/\A\d+\z/)
          unless raw.match?(/\Av\d+\z/)
            raise Thor::Error, "Versão da API inválida: #{version.inspect}. Use o formato v1, v2, etc."
          end

          raw
        end
      end

      def target_version_module
        @target_version_module ||= target_version.camelize
      end

      def ensure_base_controllers
        version_base = File.join("app/controllers/api", target_version, "base_controller.rb")
        return if File.exist?(File.join(destination_root, version_base))

        template "api/version_base_controller.rb.tt", version_base
      end

      def ensure_routes_namespace
        routes_path = File.join(destination_root, "config/routes.rb")
        return unless File.exist?(routes_path)

        content = File.read(routes_path)
        return if content.match?(/^    namespace :#{Regexp.escape(target_version)} do\r?\n/)

        eol = content.include?("\r\n") ? "\r\n" : "\n"
        if content.match?(/^  namespace :api do\r?\n/)
          block = "    namespace :#{target_version} do#{eol}    end#{eol}"
          inject_into_file "config/routes.rb", block, after: /^  namespace :api do\r?\n/
        else
          block = "  namespace :api do#{eol}    namespace :#{target_version} do#{eol}    end#{eol}  end#{eol}"
          inject_into_file "config/routes.rb", block, after: /^Rails\.application\.routes\.draw do\r?\n/
        end
      end

      def ensure_swagger_configuration
        ensure_swagger_helper_entry
        ensure_rswag_ui_entry
      end

      def ensure_swagger_helper_entry
        helper_path = File.join(destination_root, "spec/swagger_helper.rb")
        return unless File.exist?(helper_path)

        content = File.read(helper_path)
        spec_key = %("#{target_version}/swagger.yaml")
        return if content.include?(spec_key)

        eol = content.include?("\r\n") ? "\r\n" : "\n"
        if content.include?("build_openapi_spec")
          entry = "    #{spec_key} => build_openapi_spec.call(\"#{target_version}\"),#{eol}"
          inject_into_file "spec/swagger_helper.rb", entry, after: /config\.openapi_specs = \{\r?\n/
        else
          say_status :skip, "spec/swagger_helper.rb não usa build_openapi_spec; adicione #{spec_key} manualmente", :yellow
        end
      end

      def ensure_rswag_ui_entry
        ui_path = File.join(destination_root, "config/initializers/rswag_ui.rb")
        return unless File.exist?(ui_path)

        content = File.read(ui_path)
        endpoint = "/api-docs/#{target_version}/swagger.yaml"
        return if content.include?(endpoint)

        eol = content.include?("\r\n") ? "\r\n" : "\n"
        entry = %(  c.openapi_endpoint "#{endpoint}", "Ordem OS API #{target_version}"#{eol})
        if content.match?(/c\.openapi_endpoint [^\n]+\r?\n/)
          inject_into_file "config/initializers/rswag_ui.rb", entry, after: /c\.openapi_endpoint [^\n]+\r?\n/
        else
          inject_into_file "config/initializers/rswag_ui.rb", entry, after: /Rswag::Ui\.configure do \|c\|\r?\n/
        end
      end
    end
  end
end
