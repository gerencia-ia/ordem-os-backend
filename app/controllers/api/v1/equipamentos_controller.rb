# frozen_string_literal: true

module Api
  module V1
    class EquipamentosController < ApplicationController
      before_action :set_equipamento, only: [:show, :update, :destroy, :historico_laudos]

      def index
        if params[:cliente_id].present?
          @equipamentos = Equipamento.where(cliente_id: params[:cliente_id])
        else
          @equipamentos = Equipamento.all
        end
        render json: @equipamentos
      end

      def show
        render json: @equipamento
      end

      def create
        @equipamento = Equipamento.new(equipamento_params)
        if @equipamento.save
          render json: @equipamento, status: :created
        else
          render json: @equipamento.errors, status: :unprocessable_entity
        end
      end

      def update
        if @equipamento.update(equipamento_params)
          render json: @equipamento
        else
          render json: @equipamento.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @equipamento.destroy
        head :no_content
      end

      # Retorna o histórico de laudos do equipamento em todas as ordens de serviço
      def historico_laudos
        laudos = OsEquipamento.includes(ordem_servico: [:status, :prioridade])
                              .where(equipamento_id: @equipamento.id)
                              .where.not(laudo: [nil, ''])
                              .order('ordem_servicos.created_at DESC')

        resultado = laudos.map do |oe|
          {
            id: oe.id,
            laudo: oe.laudo,
            created_at: oe.created_at,
            updated_at: oe.updated_at,
            ordem_servico: {
              id: oe.ordem_servico.id,
              numero_ordem: oe.ordem_servico.numero_ordem,
              descricao: oe.ordem_servico.descricao,
              data_agendamento: oe.ordem_servico.data_agendamento,
              data_fechamento: oe.ordem_servico.data_fechamento,
              status: oe.ordem_servico.status&.nome,
              prioridade: oe.ordem_servico.prioridade&.descricao
            }
          }
        end

        render json: resultado
      end

      private

      def set_equipamento
        @equipamento = Equipamento.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def equipamento_params
        params.require(:equipamento).permit(:marca, :btus, :local_instalacao, :observacao, :cliente_id)
      end
    end
  end
end
