# frozen_string_literal: true

require_relative "../../scaffold/api/base"

module Api
  class ScaffoldGenerator < ::Scaffold::Api::Base
    class_option :skip_routes, type: :boolean, default: false, desc: "Não altera config/routes.rb"

    def generate_api_scaffold
      ensure_api_version_components!(
        controllers: true,
        routes: !options[:skip_routes],
        swagger: true
      )
      opts = forwarded_api_options
      invoke "scaffold:api:controller", [ name ] + args, opts
      invoke "scaffold:api:serializer", [ name ] + args, opts
      invoke "scaffold:api:policy", [ name ], opts
      invoke "scaffold:api:route", [ name ], opts unless options[:skip_routes]
      invoke "scaffold:api:spec", [ name ] + args, opts.merge("skip_model" => true)
    end
  end
end
