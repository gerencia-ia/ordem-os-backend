# frozen_string_literal: true

module Api
  module V1
    class RolesController < BaseController
      before_action :set_role, only: %i[ show update destroy ]

      # GET /roles
      def index
        authorize! Role
        @roles = Role.all

        render json: @roles
      end

      # GET /roles/1
      def show
        authorize! @role

        render json: @role
      end

      # POST /roles
      def create
        authorize! Role
        @role = Role.new(role_params)

        if @role.save
          render json: @role, status: :created
        else
          render json: @role.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /roles/1
      def update
        authorize! @role

        if @role.update(role_params)
          render json: @role
        else
          render json: @role.errors, status: :unprocessable_entity
        end
      end

      # DELETE /roles/1
      def destroy
        authorize! @role
        @role.destroy!

        head :no_content
      end

      private

      def set_role
        @role = Role.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def role_params
        params.require(:role).permit(:nome)
      end
    end
  end
end
