# frozen_string_literal: true

class Equipamento < ApplicationRecord
  normalizes :marca, :local_instalacao, :observacao, with: ->(s) { s&.strip }

  belongs_to :cliente, inverse_of: :equipamentos
  belongs_to :andar, inverse_of: :equipamentos
  has_many :os_equipamentos, dependent: :restrict_with_error, inverse_of: :equipamento
  has_many :ordem_servicos, through: :os_equipamentos, source: :ordem_servico
  has_many :os_servicos, dependent: :restrict_with_error, inverse_of: :equipamento

  validates :marca, :local_instalacao, presence: true

  scope :por_cliente, ->(cliente_id) { where(cliente_id: cliente_id) }
end
