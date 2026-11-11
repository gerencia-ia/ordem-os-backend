# frozen_string_literal: true

class ValorPorAndar < ApplicationRecord
  belongs_to :servico, inverse_of: :valores_por_andares
  belongs_to :andar, inverse_of: :valores_por_andares

  has_many :os_servicos, dependent: :restrict_with_error, inverse_of: :valor_por_andar

  validates :valor, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :andar_id, uniqueness: { scope: :servico_id, message: "já possui valor cadastrado para este serviço" }
end
