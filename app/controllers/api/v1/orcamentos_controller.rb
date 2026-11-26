# frozen_string_literal: true

module Api
  module V1
    class OrcamentosController < BaseController
      before_action :set_orcamento, only: [ :show, :update, :destroy, :update_status, :converter_em_os ]

      def index
        authorize! Orcamento

        @orcamentos = base_scope
        @orcamentos = @orcamentos.por_cliente(params[:cliente_id]) if params[:cliente_id].present?
        @orcamentos = @orcamentos.por_status(params[:status]) if params[:status].present?
        @orcamentos = @orcamentos.por_mes_e_ano(params[:mes], params[:ano]) if params[:mes].present? && params[:ano].present?
        @orcamentos = @orcamentos.recentes

        render json: @orcamentos
      end

      def show
        authorize! @orcamento
        render json: @orcamento
      end

      def create
        authorize! Orcamento

        if params.dig(:orcamento, :status).to_s == "convertido"
          return render json: { error: "Status 'convertido' não pode ser definido manualmente" },
                        status: :unprocessable_entity
        end

        @orcamento = Orcamento.new(orcamento_params)

        if @orcamento.save
          render json: @orcamento, status: :created
        else
          render_validation_errors(@orcamento)
        end
      end

      def update
        authorize! @orcamento

        if @orcamento.convertido?
          return render json: { error: "Não é possível alterar um orçamento já convertido em Ordem de Serviço" },
                        status: :unprocessable_entity
        end

        if params.dig(:orcamento, :status).to_s == "convertido"
          return render json: { error: "Status 'convertido' não pode ser definido manualmente" },
                        status: :unprocessable_entity
        end

        if @orcamento.update(orcamento_params)
          render json: @orcamento
        else
          render_validation_errors(@orcamento)
        end
      end

      def destroy
        authorize! @orcamento

        if @orcamento.convertido?
          return render json: { error: "Não é possível excluir um orçamento já convertido em Ordem de Serviço" },
                        status: :unprocessable_entity
        end

        @orcamento.destroy
        head :no_content
      end

      def update_status
        authorize! @orcamento, to: :update_status?

        if @orcamento.convertido?
          return render json: { error: "Não é possível alterar o status de um orçamento já convertido em Ordem de Serviço" },
                        status: :unprocessable_entity
        end

        novo_status = params[:status].to_s
        unless Orcamento::STATUSES_EDITAVEIS.include?(novo_status)
          return render json: { error: "Status inválido para atualização manual" },
                        status: :unprocessable_entity
        end

        if @orcamento.update(status: novo_status)
          render json: @orcamento
        else
          render_validation_errors(@orcamento)
        end
      end

      def converter_em_os
        authorize! @orcamento, to: :converter_em_os?

        ordem_servico = Orcamentos::ConverterEmOs.new(@orcamento, converter_params).call
        render json: ordem_servico, serializer: OrdemServicoSerializer, status: :created
      rescue Orcamentos::ConverterEmOs::Error => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render_validation_errors(e.record)
      end

      private

      def base_scope
        Orcamento.includes(
          :endereco, :ordem_servico,
          cliente: [ :telefones, :enderecos ],
          orcamento_equipamentos: { equipamento: :andar },
          orcamento_servicos: { valor_por_andar: [ :andar, { servico: :categorias_servico } ] },
          orcamento_materiais: :material
        )
      end

      def set_orcamento
        @orcamento = base_scope.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      def orcamento_params
        params.require(:orcamento).permit(
          :cliente_id, :endereco_id, :status, :data_validade,
          :desconto, :condicoes_pagamento, :observacao,
          equipamento_ids: [],
          orcamento_servicos_attributes: [ :id, :equipamento_id, :valor_por_andar_id, :quantidade, :_destroy ],
          orcamento_materiais_attributes: [ :id, :material_id, :nome_material, :valor, :_destroy ]
        )
      end

      def converter_params
        params.permit(:prioridade_id, :status_id, :data_agendamento, :descricao, :observacao, tecnico_ids: [], user_ids: [])
      end
    end
  end
end
