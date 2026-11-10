# frozen_string_literal: true

class OsEquipamento < ApplicationRecord
  normalizes :laudo, with: ->(l) { l&.strip }

  belongs_to :ordem_servico, inverse_of: :os_equipamentos
  belongs_to :equipamento, inverse_of: :os_equipamentos

  validates :equipamento, :ordem_servico, presence: true
  validates :equipamento_id, uniqueness: { scope: :ordem_servico_id, message: "já está vinculado a esta ordem de serviço" }

  validate :equipamento_deve_pertencer_ao_cliente_da_os

  private

  def equipamento_deve_pertencer_ao_cliente_da_os
    return if ordem_servico.blank? || equipamento.blank?
    return if ordem_servico.cliente_id == equipamento.cliente_id

    errors.add(:equipamento_id, "deve pertencer ao mesmo cliente da ordem de serviço")
  end
end
