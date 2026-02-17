# frozen_string_literal: true

module Api
  module V1
    class ServicosController < ApplicationController
      before_action :set_servico, only: [:show, :update, :destroy]

      def index
        @servicos = Servico.includes(:categorias_servico).all
        render json: @servicos, include: :categorias_servico
      end

      def show
        render json: @servico
      end

      def create
        @servico = Servico.new(servico_params)
        if @servico.save
          render json: @servico, status: :created
        else
          render json: @servico.errors, status: :unprocessable_entity
        end
      end

      def update
        if @servico.update(servico_params)
          render json: @servico
        else
          render json: @servico.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @servico.destroy
        head :no_content
      end

      private

      def set_servico
        @servico = Servico.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def servico_params
        params.require(:servico).permit(:nome, :valor, :tempo_servico, :categorias_servico_id)
      end
    end
  end
end
