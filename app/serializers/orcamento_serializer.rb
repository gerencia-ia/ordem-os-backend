# frozen_string_literal: true

class OrcamentoSerializer < ActiveModel::Serializer
  attributes :id, :numero_orcamento, :status, :data_validade,
             :subtotal_servicos, :subtotal_materiais, :desconto, :valor_total,
             :condicoes_pagamento, :observacao, :ordem_servico_id, :ordem_servico,
             :created_at, :updated_at

  belongs_to :cliente
  belongs_to :endereco

  has_many :equipamentos, serializer: OrcamentoEquipamentoSerializer
  has_many :servicos, serializer: OrcamentoServicoSerializer
  has_many :materiais, serializer: OrcamentoMaterialSerializer

  def equipamentos
    object.orcamento_equipamentos
  end

  def servicos
    object.orcamento_servicos
  end

  def materiais
    object.orcamento_materiais
  end

  def ordem_servico
    return nil unless object.ordem_servico

    {
      id: object.ordem_servico.id,
      numero_ordem: object.ordem_servico.numero_ordem
    }
  end
end
