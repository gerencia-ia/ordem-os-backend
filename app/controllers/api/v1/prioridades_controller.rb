# frozen_string_literal: true

module Api
  module V1
    class PrioridadesController < BaseController
      before_action :set_prioridade, only: [ :show, :update, :destroy ]

      def index
        authorize! Prioridade
        @prioridades = Prioridade.all
        render json: @prioridades
      end

      def show
        authorize! @prioridade
        render json: @prioridade
      end

      def create
        authorize! Prioridade
        @prioridade = Prioridade.new(prioridade_params)
        if @prioridade.save
          render json: @prioridade, status: :created
        else
          render_validation_errors(@prioridade)
        end
      end

      def update
        authorize! @prioridade
        if @prioridade.update(prioridade_params)
          render json: @prioridade
        else
          render_validation_errors(@prioridade)
        end
      end

      def destroy
        authorize! @prioridade
        @prioridade.destroy
        head :no_content
      end

      private

      def set_prioridade
        @prioridade = Prioridade.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def prioridade_params
        params.require(:prioridade).permit(:descricao)
      end
    end
  end
end
