# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [ :show, :update, :destroy ]

      def index
        authorize! User
        users = User.includes(:role).all

        render json: users
      end

      def show
        authorize! @user

        render json: @user
      end

      def create
        authorize! User
        user = User.new(user_params)

        if user.save
          render json: user, status: :created
        else
          render_validation_errors(user)
        end
      end

      def update
        authorize! @user

        if @user.update(user_params)
          render json: @user
        else
          render_validation_errors(@user)
        end
      end

      def destroy
        authorize! @user
        @user.destroy

        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def user_params
        data = params[:user].present? ? params.require(:user) : params

        permitted_attributes = [ :nome, :cpf, :email, :telefone, :password ]
        permitted_attributes << :role_id if current_user&.admin?

        p = data.permit(permitted_attributes)
        p.delete(:password) if p[:password].blank?

        p
      end
    end
  end
end
