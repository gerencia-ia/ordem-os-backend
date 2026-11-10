# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      allow_unauthenticated_access only: :create

      rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
        render json: { error: "Muitas tentativas de login. Tente novamente mais tarde." }, status: :too_many_requests
      }

      def create
        cpf = params[:cpf].to_s.gsub(/\D/, "")
        user = User.authenticate_by(cpf: cpf, password: params[:password])

        if user
          session = user.sessions.create!(
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          )

          render json: {
            token: session.token,
            user: UserSerializer.new(user)
          }, status: :ok
        else
          render json: { error: "CPF ou senha inválidos" }, status: :unauthorized
        end
      end

      def destroy
        Current.session&.destroy
        head :no_content
      end
    end
  end
end
