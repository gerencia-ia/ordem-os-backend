# frozen_string_literal: true

require "rails/generators"

class PolicyGenerator < Rails::Generators::NamedBase
  def create_policy_file
    invoke "scaffold:api:policy", [ name ]
  end
end
