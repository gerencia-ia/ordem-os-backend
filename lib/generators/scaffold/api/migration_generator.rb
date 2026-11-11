# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class MigrationGenerator < Base
      def create_migration_file
        target_name =
          if file_name.match?(/\A(create|add|remove|create_join_table)_/)
            file_name
          else
            "create_#{normalized_plural_name}"
          end

        migration_target = File.join(*api_class_path, target_name)
        invoke "active_record:migration", [ migration_target ] + args
      end
    end
  end
end
