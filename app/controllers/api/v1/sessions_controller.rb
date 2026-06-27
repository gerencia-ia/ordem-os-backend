# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      DEMO_ACCOUNTS = [
        {
          profile: 'secretaria',
          cpf: '11111111111',
          senha: '123456'
        },
        {
          profile: 'tecnico',
          cpf: '22222222222',
          senha: '123456'
        }
      ].freeze

      def demo
        if Rails.env.development?
          render json: { demo_accounts: DEMO_ACCOUNTS }, status: :ok
        else
          head :not_found
        end
      end

      def create
        user = User.find_by(cpf: params[:cpf])
        if user&.authenticate(params[:senha])
          secret = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
          
          payload = { user_id: user.id, role: user.role }
          
          # Se for técnico, incluir tecnico_id no token
          if user.role == 1 # técnico
            tecnico = Tecnico.find_by(cpf: user.cpf)
            payload[:tecnico_id] = tecnico.id if tecnico
          end
          
          token = JWT.encode(payload, secret)
          response = { token: token, role: user.role, tecnico_id: payload[:tecnico_id] }
          response[:demo_accounts] = DEMO_ACCOUNTS if Rails.env.development?

          render json: response, status: :ok
        else
          render json: { error: 'CPF ou senha inválidos' }, status: :unauthorized
        end
      end
    end
  end
end
