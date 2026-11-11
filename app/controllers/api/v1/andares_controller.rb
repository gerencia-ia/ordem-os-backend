# frozen_string_literal: true

module Api
  module V1
    class AndaresController < BaseController
      before_action :set_andar, only: [ :show, :update, :destroy ]

      def index
        authorize! Andar
        @andares = Andar.all
        render json: @andares
      end

      def show
        authorize! @andar
        render json: @andar
      end

      def create
        authorize! Andar
        @andar = Andar.new(andar_params)

        if @andar.save
          render json: @andar, status: :created
        else
          render_validation_errors(@andar)
        end
      end

      def update
        authorize! @andar

        if @andar.update(andar_params)
          render json: @andar
        else
          render_validation_errors(@andar)
        end
      end

      def destroy
        authorize! @andar
        @andar.destroy
        head :no_content
      end

      private

      def set_andar
        @andar = Andar.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def andar_params
        params.require(:andar).permit(:descricao)
      end
    end
  end
end
