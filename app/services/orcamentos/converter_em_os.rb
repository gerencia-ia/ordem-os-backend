# frozen_string_literal: true

module Orcamentos
  class ConverterEmOs
    class Error < StandardError; end

    def initialize(orcamento, params = {})
      @orcamento = orcamento
      @params = params.to_h.with_indifferent_access
    end

    def call
      @orcamento.with_lock do
        validar_estado!

        status = resolver_status!
        prioridade = resolver_prioridade!
        tecnico_ids = resolver_tecnico_ids

        ordem_servico = OrdemServico.create!(
          cliente_id: @orcamento.cliente_id,
          endereco_id: @orcamento.endereco_id,
          status: status,
          prioridade: prioridade,
          data_agendamento: @params[:data_agendamento].presence,
          descricao: @params[:descricao].presence || "Ordem de serviço gerada a partir do orçamento #{@orcamento.numero_orcamento}",
          observacao: resolver_observacao,
          valor_total: @orcamento.valor_total,
          custo_estimado: @orcamento.valor_total,
          equipamento_ids: @orcamento.equipamento_ids,
          user_ids: tecnico_ids,
          os_servicos_attributes: montar_servicos_attributes,
          os_materiais_attributes: montar_materiais_attributes
        )

        @orcamento.update!(ordem_servico: ordem_servico, status: "convertido")

        ordem_servico
      end
    end

    private

    def validar_estado!
      if @orcamento.convertido? || @orcamento.ordem_servico_id.present?
        raise Error, "Este orçamento já foi convertido em Ordem de Serviço"
      end

      unless @orcamento.aprovado?
        raise Error, "Apenas orçamentos aprovados podem ser convertidos em Ordem de Serviço"
      end
    end

    def resolver_status!
      if @params[:status_id].present?
        Status.find_by(id: @params[:status_id]) || raise(Error, "Status inválido")
      else
        Status.find_by("LOWER(nome) = ?", "não iniciada") ||
          Status.order(:id).first ||
          raise(Error, "Nenhum status cadastrado no sistema")
      end
    end

    def resolver_prioridade!
      if @params[:prioridade_id].present?
        Prioridade.find_by(id: @params[:prioridade_id]) || raise(Error, "Prioridade inválida")
      else
        Prioridade.find_by("LOWER(descricao) = ?", "média") ||
          Prioridade.order(:id).first ||
          raise(Error, "Nenhuma prioridade cadastrada no sistema")
      end
    end

    def resolver_tecnico_ids
      Array(@params[:tecnico_ids].presence || @params[:user_ids]).reject(&:blank?).map(&:to_i).uniq
    end

    def resolver_observacao
      return @params[:observacao] if @params[:observacao].present?

      [
        @orcamento.observacao.presence,
        "Originada do orçamento #{@orcamento.numero_orcamento}"
      ].compact.join("\n")
    end

    def montar_servicos_attributes
      @orcamento.orcamento_servicos.map do |item|
        {
          equipamento_id: item.equipamento_id,
          valor_por_andar_id: item.valor_por_andar_id,
          quantidade: item.quantidade,
          nome_servico: item.nome_servico,
          valor_unitario: item.valor_unitario
        }
      end
    end

    def montar_materiais_attributes
      @orcamento.orcamento_materiais.map do |item|
        {
          material_id: item.material_id,
          nome_material: item.nome_material,
          valor: item.valor
        }
      end
    end
  end
end
