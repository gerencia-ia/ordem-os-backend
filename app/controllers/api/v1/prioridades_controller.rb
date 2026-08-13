# frozen_string_literal: true

module Api
  module V1
    class PrioridadesController < BaseController
      before_action :set_prioridade, only: [:show, :update, :destroy]

      def index
        @prioridades = Prioridade.all
        render json: @prioridades
      end

      def show
        render json: @prioridade
      end

      def create
        @prioridade = Prioridade.new(prioridade_params)
        if @prioridade.save
          render json: @prioridade, status: :created
        else
          render json: @prioridade.errors, status: :unprocessable_entity
        end
      end

      def update
        if @prioridade.update(prioridade_params)
          render json: @prioridade
        else
          render json: @prioridade.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @prioridade.destroy
        head :no_content
      end

      private

      def set_prioridade
        @prioridade = Prioridades.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def prioridade_params
        params.require(:prioridade).permit(descricao)
      end
    end
  end
end
