# frozen_string_literal: true

class OrcamentoServico < ApplicationRecord
  belongs_to :orcamento, inverse_of: :orcamento_servicos
  belongs_to :valor_por_andar, inverse_of: :orcamento_servicos
  belongs_to :equipamento, inverse_of: :orcamento_servicos

  has_one :servico, through: :valor_por_andar
  has_one :andar, through: :valor_por_andar

  before_validation :set_default_quantidade
  before_validation :registrar_dados_do_catalogo, on: :create

  validates :orcamento, :valor_por_andar, :equipamento, presence: true
  validates :valor_por_andar_id, uniqueness: {
    scope: [ :orcamento_id, :equipamento_id ],
    message: "já está adicionado para este equipamento neste orçamento"
  }
  validates :quantidade, numericality: { greater_than: 0 }

  validate :equipamento_deve_pertencer_ao_cliente_do_orcamento

  private

  def registrar_dados_do_catalogo
    return unless valor_por_andar

    self.nome_servico ||= valor_por_andar.servico&.nome
    self.valor_unitario ||= valor_por_andar.valor
  end

  def set_default_quantidade
    self.quantidade ||= 1
  end

  def equipamento_deve_pertencer_ao_cliente_do_orcamento
    return if orcamento.blank? || equipamento.blank?
    return if orcamento.cliente_id == equipamento.cliente_id

    errors.add(:equipamento_id, "deve pertencer ao mesmo cliente do orçamento")
  end
end
