# frozen_string_literal: true

class OsServico < ApplicationRecord
  belongs_to :ordem_servico, inverse_of: :os_servicos
  belongs_to :servico, inverse_of: :os_servicos

  before_validation :set_default_quantidade

  validates :servico, :ordem_servico, presence: true
  validates :servico_id, uniqueness: { scope: :ordem_servico_id, message: "já está adicionado a esta ordem de serviço" }
  validates :quantidade, numericality: { greater_than: 0 }

  private

  def set_default_quantidade
    self.quantidade ||= 1
  end
end
