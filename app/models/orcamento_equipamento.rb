# frozen_string_literal: true

class OrcamentoEquipamento < ApplicationRecord
  belongs_to :orcamento, inverse_of: :orcamento_equipamentos
  belongs_to :equipamento, inverse_of: :orcamento_equipamentos

  validates :equipamento, :orcamento, presence: true
  validates :equipamento_id, uniqueness: { scope: :orcamento_id, message: "já está vinculado a este orçamento" }

  validate :equipamento_deve_pertencer_ao_cliente_do_orcamento

  private

  def equipamento_deve_pertencer_ao_cliente_do_orcamento
    return if orcamento.blank? || equipamento.blank?
    return if orcamento.cliente_id == equipamento.cliente_id

    errors.add(:equipamento_id, "deve pertencer ao mesmo cliente do orçamento")
  end
end
