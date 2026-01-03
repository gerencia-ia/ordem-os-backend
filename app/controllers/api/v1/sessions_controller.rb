# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      def create
        user = User.find_by(cpf: params[:cpf])
        if user&.authenticate(params[:senha])
          token = JWT.encode({ user_id: user.id, role: user.role }, Rails.application.credentials.secret_key_base || Rails.application.secret_key_base)
          render json: { token: token, role: user.role }, status: :ok
        else
          render json: { error: 'CPF ou senha inválidos' }, status: :unauthorized
        end
      end
    end
  end
end
