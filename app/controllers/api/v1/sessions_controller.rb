# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      def create
        user = User.find_by(cpf: params[:cpf])
        if user&.authenticate(params[:senha])

          secret = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
          payload = { user_id: user.id, nome: user.nome, cpf: user.cpf, role: user.role.nome }
          
          token = JWT.encode(payload, secret)
          response = { token: token }

          render json: response, status: :ok
        else
          render json: { error: 'CPF ou senha inválidos' }, status: :unauthorized
        end
      end
    end
  end
end
