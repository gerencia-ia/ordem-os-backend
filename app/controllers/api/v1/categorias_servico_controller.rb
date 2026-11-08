# frozen_string_literal: true

module Api
  module V1
    class CategoriasServicoController < BaseController
      before_action :set_categoria, only: [ :show, :update, :destroy ]

      def index
        authorize! CategoriasServico
        @categorias = CategoriasServico.all
        render json: @categorias
      end

      def show
        authorize! @categoria
        render json: @categoria
      end

      def create
        authorize! CategoriasServico
        @categoria = CategoriasServico.new(categoria_params)
        if @categoria.save
          render json: @categoria, status: :created
        else
          render json: @categoria.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize! @categoria
        if @categoria.update(categoria_params)
          render json: @categoria
        else
          render json: @categoria.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize! @categoria
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
