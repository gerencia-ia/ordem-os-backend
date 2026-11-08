# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Authentication
  include ActionPolicy::Controller

  authorize :user, through: :current_user

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  private

  def render_validation_errors(record)
    render json: {
      errors: record.errors.full_messages,
      details: record.errors.messages
    }, status: :unprocessable_entity
  end

  def user_not_authorized(exception)
    render json: {
      error: "Acesso negado",
      rule: exception.rule
    }, status: :forbidden
  end
end
