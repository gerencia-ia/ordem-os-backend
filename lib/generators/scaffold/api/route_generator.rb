# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class RouteGenerator < Base
      def add_resource_route
        routes_path = File.join(destination_root, "config/routes.rb")
        return unless File.exist?(routes_path)

        if behavior == :invoke
          invoke_route(routes_path)
        else
          revoke_route(routes_path)
        end
      end

      private

      def invoke_route(routes_path)
        ensure_api_version_components!(routes: true)

        content = File.read(routes_path)
        eol = content.include?("\r\n") ? "\r\n" : "\n"
        snippet = build_route_snippet(eol)
        span = find_version_block_span(content)

        if span
          body_start, body_end = span
          version_block = content[body_start...body_end]

          if route_already_present?(version_block)
            say_status :identical, "resources :#{normalized_plural_name} já existe em config/routes.rb (#{api_version})", :blue
            return
          end

          inject_into_file "config/routes.rb",
                           snippet,
                           after: /^[ \t]*namespace :#{Regexp.escape(api_version)} do\r?\n/,
                           force: true
        elsif options[:pretend]
          say_status :insert, "config/routes.rb (resources :#{normalized_plural_name} em namespace :#{api_version})", :green
        else
          route "resources :#{normalized_plural_name}", namespace: [ "api", api_version ] + api_class_path
        end
      end

      def revoke_route(routes_path)
        content = File.read(routes_path)
        span = find_version_block_span(content)
        return unless span

        body_start, body_end = span
        version_block = content[body_start...body_end]
        updated_block = remove_route_from_block(version_block)
        return if updated_block == version_block

        say_status :subtract, "config/routes.rb (#{api_version})", :red
        return if options[:pretend]

        updated_content = content[0...body_start] + updated_block + content[body_end..]
        File.write(routes_path, updated_content)
      end

      def route_already_present?(version_block)
        if api_class_path.empty?
          version_block.match?(/^\s*resources\s+:#{Regexp.escape(normalized_plural_name)}\b/)
        else
          normalized_block = version_block.gsub("\r\n", "\n")
          normalized_block.include?(build_route_snippet("\n"))
        end
      end

      def remove_route_from_block(version_block)
        if api_class_path.empty?
          version_block.sub(/^[ \t]*resources :#{Regexp.escape(normalized_plural_name)}\r?\n/, "")
        else
          pattern = Regexp.escape(build_route_snippet("\n")).gsub('\n', '\r?\n')
          version_block.sub(/#{pattern}/, "")
        end
      end

      def find_version_block_span(content)
        match = content.match(/^[ \t]*namespace :#{Regexp.escape(api_version)} do\r?\n/)
        return nil unless match

        body_start = match.end(0)
        depth = 1
        offset = body_start

        content[body_start..].each_line do |line|
          code = line.sub(/#.*$/, "").rstrip
          depth += 1 if code.match?(/\bdo(?:\s*\|[^|]*\|)?\z/)
          if code.match?(/\A\s*end\b/)
            depth -= 1
            return [ body_start, offset ] if depth.zero?
          end
          offset += line.length
        end

        nil
      end

      def build_route_snippet(eol = "\n")
        if api_class_path.empty?
          "      resources :#{normalized_plural_name}#{eol}"
        else
          indent_level = 6
          opening = api_class_path.each_with_index.map do |ns, idx|
            "#{' ' * (indent_level + idx * 2)}namespace :#{ns} do#{eol}"
          end.join
          body = "#{' ' * (indent_level + api_class_path.size * 2)}resources :#{normalized_plural_name}#{eol}"
          closing = api_class_path.each_with_index.reverse_each.map do |_, idx|
            "#{' ' * (indent_level + idx * 2)}end#{eol}"
          end.join
          opening + body + closing
        end
      end
    end
  end
end
