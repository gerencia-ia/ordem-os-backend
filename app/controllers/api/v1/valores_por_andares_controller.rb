# frozen_string_literal: true

module Api
  module V1
    class ValoresPorAndaresController < BaseController
      before_action :set_valor_por_andar, only: [ :show, :update, :destroy ]

      def index
        authorize! ValorPorAndar
        @valores_por_andares = ValorPorAndar.all
        render json: @valores_por_andares
      end

      def show
        authorize! @valor_por_andar
        render json: @valor_por_andar
      end

      def create
        authorize! ValorPorAndar
        @valor_por_andar = ValorPorAndar.new(valor_por_andar_params)

        if @valor_por_andar.save
          render json: @valor_por_andar, status: :created
        else
          render_validation_errors(@valor_por_andar)
        end
      end

      def update
        authorize! @valor_por_andar

        if @valor_por_andar.update(valor_por_andar_params)
          render json: @valor_por_andar
        else
          render_validation_errors(@valor_por_andar)
        end
      end

      def destroy
        authorize! @valor_por_andar
        @valor_por_andar.destroy
        head :no_content
      end

      private

      def set_valor_por_andar
        @valor_por_andar = ValorPorAndar.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def valor_por_andar_params
        params.require(:valor_por_andar).permit(:servico_id, :andar_id, :valor)
      end
    end
  end
end
