# frozen_string_literal: true

module Api
  module V1
    class ClientesController < ApplicationController
      before_action :set_cliente, only: [:show, :update, :destroy]

      def index
        clientes = Cliente.includes(:telefones, :enderecos).all
        render json: clientes.as_json(include: [:telefones, :enderecos])
      end

      def show
        cliente = Cliente.includes(:telefones, :enderecos).find(params[:id])
        render json: cliente.as_json(include: [:telefones, :enderecos])
      end

      def create
        assign_nested_params

        cliente = Cliente.new(cliente_params)
        if cliente.save
          render_cliente(cliente, :created)
        else
          render json: cliente.errors, status: :unprocessable_entity
        end
      end

      def update
        assign_nested_params

        if @cliente.update(cliente_params)
          render_cliente(@cliente)
        else
          render json: @cliente.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @cliente.destroy
        head :no_content
      end

      private

      def set_cliente
        @cliente = Cliente.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def cliente_params
        params.require(:cliente).permit(
          :nome, :email, :data_registro, :data_ultima_visita,
          enderecos_attributes: [:id, :rua, :numero, :bairro, :complemento, :cep, :cidade, :_destroy],
          telefones_attributes: [:id, :numero, :tipo, :_destroy],
          equipamentos_attributes: [:id, :marca, :btus, :local_instalacao, :observacao, :_destroy]
        )
      end

      def assign_nested_params
        params[:cliente] ||= {}
        params[:cliente][:enderecos_attributes] = params[:enderecos] if params[:enderecos]
        params[:cliente][:telefones_attributes] = params[:telefones] if params[:telefones]
      end

      def render_cliente(cliente, status = :ok)
        render json: cliente.as_json(include: [:enderecos, :telefones]), status: status
      end
    end
  end
end
