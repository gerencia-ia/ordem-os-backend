# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_request!

      private

      def authenticate_request!
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        begin
          decoded = JWT.decode(header, Rails.application.credentials.secret_key_base || Rails.application.secret_key_base)[0]
          @current_user = User.find(decoded['user_id'])
        rescue
          render json: { error: 'Não autorizado' }, status: :unauthorized
        end
      end

      def require_role!(*roles)
        unless roles.include?(@current_user.role)
          render json: { error: 'Acesso negado' }, status: :forbidden
        end
      end
    end
  end
end
