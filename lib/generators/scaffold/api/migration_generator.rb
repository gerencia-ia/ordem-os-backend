# frozen_string_literal: true

require "rails/generators"
module Generators
  module Scaffold
    module Api
      class MigrationGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        argument :attributes, type: :array, default: []

        def create_migration_file
          template "create_table_migration.rb.tt", "db/migrate/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_create_#{file_name.pluralize}.rb"
        end
      end
    end
  end
end
