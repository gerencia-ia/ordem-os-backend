# frozen_string_literal: true

module Api
  module V1
    class StatusController < BaseController
      before_action :set_status, only: [:show, :update, :destroy]

      def index
        @status = Status.all
        render json: @status
      end

      def show
        render json: @status
      end

      def create
        @status = Status.new(status_params)
        if @status.save
          render json: @status, status: :created
        else
          render json: @status.errors, status: :unprocessable_entity
        end
      end

      def update
        if @status.update(status_params)
          render json: @status
        else
          render json: @status.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @status.destroy
        head :no_content
      end

      private

      def set_status
        @status = Status.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def status_params
        params.require(:status).permit(:nome)
      end
    end
  end
end
