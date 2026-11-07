module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [ :show, :update, :destroy ]

      def index
        users = User.includes(:role).all

        render json: users
      end

      def show
        user = User.find(params[:id])

        render json: user
      end

      def create
        user = User.new(user_params)

        if user.save
          render json: user, status: :created
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        user = User.find(params[:id])

        if user.update(user_params)
          render json: user
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        user = User.find(params[:id])

        user.destroy

        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def user_params
        raw_password = params[:user]&.dig(:password) || params[:user]&.dig(:senha) || params[:password] || params[:senha]
        data = params[:user].present? ? params.require(:user) : params

        p = data.permit(
          :nome,
          :cpf,
          :email,
          :telefone,
          :role_id,
          :password,
          :senha
        )

        p[:password] = raw_password if raw_password.present?
        p.delete(:senha)
        p.delete(:password) if p[:password].blank?

        p[:cpf] = p[:cpf].gsub(/\D/, "") if p[:cpf].present?
        p[:telefone] = p[:telefone].gsub(/\D/, "") if p[:telefone].present?

        p
      end
    end
  end
end
