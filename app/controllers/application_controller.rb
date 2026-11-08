# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Authentication
  include ActionPolicy::Controller

  authorize :user, through: :current_user

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    render json: {
      error: "Acesso negado",
      rule: exception.rule
    }, status: :forbidden
  end
end
