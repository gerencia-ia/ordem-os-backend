# frozen_string_literal: true

module Api
  module V1
    class TecnicosController < ApplicationController
      before_action :set_tecnico, only: [:show, :update, :destroy]

      def index
        @tecnicos = Tecnico.all
        render json: @tecnicos
      end

      def show
        render json: @tecnico
      end

    def create
        @tecnico = Tecnico.new(tecnico_params)

        ActiveRecord::Base.transaction do
          if @tecnico.save
            User.create!(
              cpf: tecnico_params[:cpf],
              password: params[:senha] || '123456',
              role: :tecnico
            )

            render json: @tecnico, status: :created
          else
            render json: @tecnico.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      end


      def update
        if @tecnico.update(tecnico_params)
          render json: @tecnico
        else
          render json: @tecnico.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @tecnico.destroy
        head :no_content
      end

      private

      def set_tecnico
        @tecnico = Tecnico.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def tecnico_params
        params.require(:tecnico).permit(:nome, :email, :telefone, :cpf, especialidades: [])
      end
    end
  end
end
