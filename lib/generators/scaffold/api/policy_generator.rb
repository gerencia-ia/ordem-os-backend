# frozen_string_literal: true

require_relative "base"

module Scaffold
  module Api
    class PolicyGenerator < Base
      def create_policy_file
        template "action_policy/policy/policy.rb.tt", policy_file_path
      end
    end
  end
end
