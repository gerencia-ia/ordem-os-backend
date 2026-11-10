# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  included do
    before_action :require_authentication
    helper_method :current_user if respond_to?(:helper_method)
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  def current_user
    Current.user
  end

  private

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_token
  end

  def find_session_by_token
    token = token_from_header
    return nil if token.blank?

    Session.includes(user: :role).find_by(token: token)
  end

  def token_from_header
    token_from_auth_helper || token_from_raw_header
  end

  def token_from_auth_helper
    token = nil
    authenticate_with_http_token do |t, _options|
      token = t
    end
    token
  end

  def token_from_raw_header
    auth_header = request.headers["Authorization"]
    return nil if auth_header.blank?

    auth_header.split(" ").last
  end

  def request_authentication
    render json: { error: "Não autorizado" }, status: :unauthorized
  end
end
