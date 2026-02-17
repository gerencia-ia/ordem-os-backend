# frozen_string_literal: true

module Api
  module V1
    class OrdemServicosController < BaseController
      before_action :set_ordem_servico, only: [:show, :update, :destroy, :update_status, :update_laudo, :add_servico, :remove_servico, :add_tecnico, :remove_tecnico]
      # Exemplo: apenas SECRETARIA pode criar e remover ordens

      def index
        # Se técnico autenticado, mostrar apenas suas OS
        if @current_user.role == 1 && @current_tecnico_id
          @ordem_servicos = OrdemServico.includes(:cliente, :tecnicos, :status, :prioridade)
            .joins(:os_tecnicos)
            .where(os_tecnicos: { tecnico_id: @current_tecnico_id })
            .distinct
        elsif params[:cliente_id].present?
          @ordem_servicos = OrdemServico.includes(:cliente, :tecnicos, :status, :prioridade)
            .where(cliente_id: params[:cliente_id])
        else
          @ordem_servicos = OrdemServico.includes(:cliente, :tecnicos, :status, :prioridade).all
        end

        # Filtro por mês na data_agendamento
        if params[:mes].present? && params[:ano].present?
          mes = params[:mes].to_i
          ano = params[:ano].to_i
          @ordem_servicos = @ordem_servicos.where(
            "EXTRACT(MONTH FROM data_agendamento) = ? AND EXTRACT(YEAR FROM data_agendamento) = ?",
            mes, ano
          )
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

      # Atualiza o laudo de um equipamento específico na OS
      def update_laudo
        os_equipamento = @ordem_servico.os_equipamentos.find_by(equipamento_id: params[:equipamento_id])
        
        if os_equipamento.nil?
          render json: { error: "Equipamento não encontrado nesta ordem de serviço" }, status: :not_found
          return
        end

        if os_equipamento.update(laudo: params[:laudo])
          render json: { 
            id: os_equipamento.id,
            equipamento_id: os_equipamento.equipamento_id,
            laudo: os_equipamento.laudo,
            ordem_servico_id: @ordem_servico.id
          }, status: :ok
        else
          render json: os_equipamento.errors, status: :unprocessable_entity
        end
      end

      # Adiciona um serviço à ordem de serviço
      def add_servico
        servico = Servico.find_by(id: params[:servico_id])
        return render json: { error: "Serviço não encontrado" }, status: :not_found unless servico

        os_servico = @ordem_servico.os_servicos.find_or_initialize_by(servico_id: servico.id)
        os_servico.quantidade = params[:quantidade] if params[:quantidade].present?

        if os_servico.save
          render json: {
            id: os_servico.id,
            ordem_servico_id: @ordem_servico.id,
            servico_id: servico.id,
            quantidade: os_servico.quantidade
          }, status: :created
        else
          render json: os_servico.errors, status: :unprocessable_entity
        end
      end

      # Remove um serviço da ordem de serviço
      def remove_servico
        os_servico = @ordem_servico.os_servicos.find_by(servico_id: params[:servico_id])
        return render json: { error: "Serviço não associado à ordem de serviço" }, status: :not_found unless os_servico

        os_servico.destroy
        head :no_content
      end

      # Adiciona um técnico à ordem de serviço (via os_tecnicos)
      def add_tecnico
        tecnico = Tecnico.find_by(id: params[:tecnico_id])
        return render json: { error: "Técnico não encontrado" }, status: :not_found unless tecnico

        os_tecnico = @ordem_servico.os_tecnicos.find_or_initialize_by(tecnico_id: tecnico.id)

        if os_tecnico.persisted?
          return render json: { id: os_tecnico.id, ordem_servico_id: @ordem_servico.id, tecnico_id: tecnico.id }, status: :ok
        end

        if os_tecnico.save
          render json: { id: os_tecnico.id, ordem_servico_id: @ordem_servico.id, tecnico_id: tecnico.id }, status: :created
        else
          render json: os_tecnico.errors, status: :unprocessable_entity
        end
      end

      # Remove um técnico da ordem de serviço (via os_tecnicos)
      def remove_tecnico
        os_tecnico = @ordem_servico.os_tecnicos.find_by(tecnico_id: params[:tecnico_id])
        return render json: { error: "Técnico não associado à ordem de serviço" }, status: :not_found unless os_tecnico

        os_tecnico.destroy
        head :no_content
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
          :data_inicio_atendimento,
          :data_fim_atendimento,
          tecnico_ids: [],
          servico_ids: [],
          equipamento_ids: [],
          os_equipamentos_attributes: [:id, :equipamento_id, :laudo, :_destroy]
        )
      end
    end
  end
end
