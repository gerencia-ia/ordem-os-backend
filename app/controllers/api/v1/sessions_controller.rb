# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
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
          render json: { token: token, role: user.role, tecnico_id: payload[:tecnico_id] }, status: :ok
        else
          render json: { error: 'CPF ou senha inválidos' }, status: :unauthorized
        end
      end
    end
  end
end
