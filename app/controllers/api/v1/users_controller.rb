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
        params.require(:user).permit(
          :nome,
          :cpf,
          :email,
          :telefone,
          :role_id
        )
      end
    end
  end
end
