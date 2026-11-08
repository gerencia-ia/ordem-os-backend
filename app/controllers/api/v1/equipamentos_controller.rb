# frozen_string_literal: true

module Api
  module V1
    class EquipamentosController < BaseController
      before_action :set_equipamento, only: [ :show, :update, :destroy, :historico_laudos ]

      def index
        authorize! Equipamento

        if params[:cliente_id].present?
          @equipamentos = Equipamento.where(cliente_id: params[:cliente_id])
        else
          @equipamentos = Equipamento.all
        end
        render json: @equipamentos
      end

      def show
        authorize! @equipamento
        render json: @equipamento
      end

      def create
        authorize! Equipamento
        @equipamento = Equipamento.new(equipamento_params)
        if @equipamento.save
          render json: @equipamento, status: :created
        else
          render_validation_errors(@equipamento)
        end
      end

      def update
        authorize! @equipamento
        if @equipamento.update(equipamento_params)
          render json: @equipamento
        else
          render_validation_errors(@equipamento)
        end
      end

      def destroy
        authorize! @equipamento
        @equipamento.destroy
        head :no_content
      end

      # Retorna o histórico de laudos do equipamento em todas as ordens de serviço
      def historico_laudos
        authorize! @equipamento, to: :historico_laudos?

        laudos = OsEquipamento.includes(ordem_servico: [ :status, :prioridade ])
                              .where(equipamento_id: @equipamento.id)
                              .where.not(laudo: [ nil, "" ])
                              .order("ordem_servicos.created_at DESC")

        render json: laudos, each_serializer: HistoricoLaudoSerializer
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
