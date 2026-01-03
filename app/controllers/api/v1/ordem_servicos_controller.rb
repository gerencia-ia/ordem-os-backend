# frozen_string_literal: true

module Api
  module V1
    class OrdemServicosController < BaseController
      before_action :set_ordem_servico, only: [:show, :update, :destroy, :update_status]
      # Exemplo: apenas SECRETARIA pode criar e remover ordens
      before_action only: [:create, :destroy] do
        require_role!('SECRETARIA')
      end
      # Exemplo: SECRETARIA e TECNICO podem atualizar status
      before_action only: [:update_status] do
        require_role!('SECRETARIA', 'TECNICO')
      end

      def index
        # Se técnico autenticado, mostrar apenas suas OS
        if @current_user.role == 1 && @current_tecnico_id
          @ordem_servicos = OrdemServico.joins(:os_tecnicos)
            .where(os_tecnicos: { tecnico_id: @current_tecnico_id })
            .distinct
        elsif params[:cliente_id].present?
          @ordem_servicos = OrdemServico.where(cliente_id: params[:cliente_id])
        else
          @ordem_servicos = OrdemServico.all
        end
        render json: @ordem_servicos
      end

      def show
        render json: @ordem_servico
      end

      def create
        @ordem_servico = OrdemServico.new(ordem_servico_params)
        if @ordem_servico.save
          render json: @ordem_servico, status: :created
        else
          render json: @ordem_servico.errors, status: :unprocessable_entity
        end
      end

      def update
        if @ordem_servico.update(ordem_servico_params)
          render json: @ordem_servico
        else
          render json: @ordem_servico.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @ordem_servico.destroy
        head :no_content
      end

      # Atualiza apenas o status_id da ordem de serviço
      def update_status
        @ordem_servico = OrdemServico.find(params[:id])
        if @ordem_servico.update(status_id: params[:status_id])
          render json: @ordem_servico
        else
          render json: @ordem_servico.errors, status: :unprocessable_entity
        end
      end

      private

      def set_ordem_servico
        @ordem_servico = OrdemServico.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def ordem_servico_params
        params.require(:ordem_servico).permit(
          :status_id,
          :data_agendamento,
          :data_fechamento,
          :observacao,
          :prioridade_id,
          :valor_total,
          :numero_ordem,
          :descricao,
          :tipo_servico,
          :data_vencimento,
          :custo_estimado,
          :cliente_id,
          tecnico_ids: [],
          servico_ids: [],
          equipamento_ids: []
        )
      end
    end
  end
end
