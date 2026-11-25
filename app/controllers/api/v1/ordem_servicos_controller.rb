# frozen_string_literal: true

module Api
  module V1
    class OrdemServicosController < BaseController
      before_action :set_ordem_servico, only: [
        :show, :update, :destroy, :update_status, :update_laudo,
        :add_equipamento, :remove_equipamento,
        :add_servico, :remove_servico, :add_material, :remove_material,
        :add_tecnico, :remove_tecnico
      ]

      def index
        authorize! OrdemServico

        @ordem_servicos = authorized_scope(
          OrdemServico.includes(
            :status, :prioridade, :endereco, :users,
            cliente: [ :telefones, :enderecos ],
            os_equipamentos: { equipamento: :andar },
            os_servicos: { servico: :categorias_servico },
            os_materiais: :material
          )
        )

        @ordem_servicos = @ordem_servicos.por_cliente(params[:cliente_id]) if params[:cliente_id].present?
        @ordem_servicos = @ordem_servicos.por_mes_e_ano(params[:mes], params[:ano]) if params[:mes].present? && params[:ano].present?

        render json: @ordem_servicos
      end

      def show
        authorize! @ordem_servico
        render json: @ordem_servico
      end

      def create
        authorize! OrdemServico
        @ordem_servico = OrdemServico.new(ordem_servico_params)

        if @ordem_servico.save
          render json: @ordem_servico, status: :created
        else
          render_validation_errors(@ordem_servico)
        end
      end

      def update
        authorize! @ordem_servico

        if @ordem_servico.update(ordem_servico_params)
          render json: @ordem_servico
        else
          render_validation_errors(@ordem_servico)
        end
      end

      def destroy
        authorize! @ordem_servico
        @ordem_servico.destroy
        head :no_content
      end

      # Atualiza apenas o status_id da ordem de serviço
      def update_status
        authorize! @ordem_servico, to: :update_status?

        if @ordem_servico.update(status_id: params[:status_id])
          render json: @ordem_servico
        else
          render_validation_errors(@ordem_servico)
        end
      end

      # Adiciona um equipamento à ordem de serviço
      def add_equipamento
        authorize! @ordem_servico, to: :add_equipamento?

        if os_finalizada?
          return render json: { error: "Não é possível alterar equipamentos de uma ordem de serviço concluída ou cancelada" },
                        status: :unprocessable_entity
        end

        equipamento = Equipamento.find_by(id: params[:equipamento_id])
        return render json: { error: "Equipamento não encontrado" }, status: :not_found unless equipamento

        os_equipamento = @ordem_servico.os_equipamentos.build(equipamento: equipamento)

        if os_equipamento.save
          @ordem_servico.os_equipamentos.reload
          render json: @ordem_servico, status: :created
        else
          render_validation_errors(os_equipamento)
        end
      end

      # Remove um equipamento da ordem de serviço
      def remove_equipamento
        authorize! @ordem_servico, to: :remove_equipamento?

        if os_finalizada?
          return render json: { error: "Não é possível alterar equipamentos de uma ordem de serviço concluída ou cancelada" },
                        status: :unprocessable_entity
        end

        os_equipamento = @ordem_servico.os_equipamentos.find_by(equipamento_id: params[:equipamento_id])
        return render json: { error: "Equipamento não associado à ordem de serviço" }, status: :not_found unless os_equipamento

        if @ordem_servico.os_servicos.exists?(equipamento_id: os_equipamento.equipamento_id)
          return render json: { error: "Não é possível remover equipamento com serviços vinculados nesta ordem de serviço" },
                        status: :unprocessable_entity
        end

        os_equipamento.destroy
        head :no_content
      end

      # Atualiza o laudo de um equipamento específico na OS
      def update_laudo
        authorize! @ordem_servico, to: :update_laudo?

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
          render_validation_errors(os_equipamento)
        end
      end

      # Adiciona um serviço à ordem de serviço
      def add_servico
        authorize! @ordem_servico, to: :add_servico?

        equipamento = @ordem_servico.equipamentos.find_by(id: params[:equipamento_id]) ||
                      Equipamento.find_by(id: params[:equipamento_id])
        return render json: { error: "Equipamento não encontrado" }, status: :not_found unless equipamento

        valor_por_andar = if params[:valor_por_andar_id].present?
          ValorPorAndar.find_by(id: params[:valor_por_andar_id])
        elsif params[:servico_id].present?
          ValorPorAndar.find_by(servico_id: params[:servico_id], andar_id: equipamento.andar_id)
        end

        return render json: { error: "Valor do serviço para o andar não encontrado" }, status: :not_found unless valor_por_andar

        os_servico = @ordem_servico.os_servicos.find_or_initialize_by(
          equipamento_id: equipamento.id,
          valor_por_andar_id: valor_por_andar.id
        )
        os_servico.quantidade = params[:quantidade] if params[:quantidade].present?
        os_servico.nome_servico ||= valor_por_andar.servico&.nome
        os_servico.valor_unitario ||= valor_por_andar.valor

        if os_servico.save
          @ordem_servico.recalcular_valor_total!
          render json: {
            id: os_servico.id,
            ordem_servico_id: @ordem_servico.id,
            servico_id: valor_por_andar.servico_id,
            equipamento_id: equipamento.id,
            valor_por_andar_id: valor_por_andar.id,
            quantidade: os_servico.quantidade,
            nome: os_servico.nome_servico,
            valor: os_servico.valor_unitario
          }, status: :created
        else
          render_validation_errors(os_servico)
        end
      end

      # Remove um serviço da ordem de serviço
      def remove_servico
        authorize! @ordem_servico, to: :remove_servico?

        os_servico = @ordem_servico.os_servicos.find_by(id: params[:servico_id])
        os_servico ||= @ordem_servico.os_servicos.joins(:valor_por_andar).find_by(valores_por_andares: { servico_id: params[:servico_id] })

        return render json: { error: "Serviço não associado à ordem de serviço" }, status: :not_found unless os_servico

        os_servico.destroy
        @ordem_servico.recalcular_valor_total!
        head :no_content
      end

      def add_material
        authorize! @ordem_servico, to: :add_servico?
        os_material = @ordem_servico.os_materiais.build(material_params_for_ordem)

        if os_material.save
          render json: @ordem_servico, status: :created
        else
          render_validation_errors(os_material)
        end
      end

      def remove_material
        authorize! @ordem_servico, to: :remove_servico?
        os_material = @ordem_servico.os_materiais.find_by(id: params[:material_id])
        return render json: { error: "Material não associado à ordem de serviço" }, status: :not_found unless os_material

        os_material.destroy
        head :no_content
      end

      # Adiciona um técnico à ordem de serviço (via os_tecnicos)
      def add_tecnico
        authorize! @ordem_servico, to: :add_tecnico?

        user = User.find_by(id: params[:user_id])
        return render json: { error: "Técnico não encontrado" }, status: :not_found unless user

        os_tecnico = @ordem_servico.os_tecnicos.find_or_initialize_by(user_id: user.id)

        if os_tecnico.persisted?
          return render json: { id: os_tecnico.id, ordem_servico_id: @ordem_servico.id, user_id: user.id }, status: :ok
        end

        if os_tecnico.save
          render json: { id: os_tecnico.id, ordem_servico_id: @ordem_servico.id, user_id: user.id }, status: :created
        else
          render_validation_errors(os_tecnico)
        end
      end

      # Remove um técnico da ordem de serviço (via os_tecnicos)
      def remove_tecnico
        authorize! @ordem_servico, to: :remove_tecnico?

        os_tecnico = @ordem_servico.os_tecnicos.find_by(user_id: params[:user_id])
        return render json: { error: "Técnico não associado à ordem de serviço" }, status: :not_found unless os_tecnico

        os_tecnico.destroy
        head :no_content
      end

      private

      def set_ordem_servico
        @ordem_servico = OrdemServico.includes(
          :status, :prioridade, :endereco, :users,
          cliente: [ :telefones, :enderecos ],
          os_equipamentos: :equipamento,
          os_servicos: { servico: :categorias_servico },
          os_materiais: :material
        ).find(params[:id])
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
          :endereco_id,
          :data_inicio_atendimento,
          :data_fim_atendimento,
          user_ids: [],
          servico_ids: [],
          equipamento_ids: [],
          os_servicos_attributes: [ :id, :equipamento_id, :valor_por_andar_id, :quantidade, :_destroy ],
          os_equipamentos_attributes: [ :id, :equipamento_id, :laudo, :_destroy ],
          os_materiais_attributes: [ :id, :material_id, :nome_material, :valor, :_destroy ]
        )
      end

      def material_params_for_ordem
        params.permit(:material_id, :nome_material, :valor)
      end

      def os_finalizada?
        [ "concluída", "concluida", "cancelada" ].include?(@ordem_servico.status&.nome&.downcase)
      end
    end
  end
end
