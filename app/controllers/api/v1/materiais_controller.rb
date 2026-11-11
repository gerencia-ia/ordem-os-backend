# frozen_string_literal: true

module Api
  module V1
    class MateriaisController < BaseController
      before_action :set_material, only: [ :show, :update, :destroy ]

      def index
        authorize! Material
        render json: Material.order(:nome)
      end

      def show
        authorize! @material
        render json: @material
      end

      def create
        authorize! Material
        @material = Material.new(material_params)
        if @material.save
          render json: @material, status: :created
        else
          render_validation_errors(@material)
        end
      end

      def update
        authorize! @material
        if @material.update(material_params)
          render json: @material
        else
          render_validation_errors(@material)
        end
      end

      def destroy
        authorize! @material
        if @material.destroy
          head :no_content
        else
          render_validation_errors(@material)
        end
      end

      private

      def set_material
        @material = Material.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def material_params
        dados = params[:material] || params[:materiai] || params
        dados.permit(:nome, :descricao, :valor_referencia)
      end
    end
  end
end
