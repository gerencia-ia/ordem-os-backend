# frozen_string_literal: true

module Api
  module V1
    class CategoriasServicoController < ApplicationController
      before_action :set_categoria, only: [:show, :update, :destroy]

      def index
        @categorias = CategoriasServico.all
        render json: @categorias
      end

      def show
        render json: @categoria
      end

      def create
        @categoria = CategoriasServico.new(categoria_params)
        if @categoria.save
          render json: @categoria, status: :created
        else
          render json: @categoria.errors, status: :unprocessable_entity
        end
      end

      def update
        if @categoria.update(categoria_params)
          render json: @categoria
        else
          render json: @categoria.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @categoria.destroy
        head :no_content
      end

      private

      def set_categoria
        @categoria = CategoriasServico.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def categoria_params
        params.require(:categorias_servico).permit(:descricao)
      end
    end
  end
end
