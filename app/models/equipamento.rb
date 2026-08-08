# frozen_string_literal: true

class Equipamento < ApplicationRecord
  belongs_to :cliente, foreign_key: :cliente_id, inverse_of: :equipamentos
  has_many :os_equipamentos, foreign_key: :equipamento_id, dependent: :destroy, inverse_of: :equipamento
  has_many :ordem_servicos, through: :os_equipamentos, source: :ordem_servico

  validates :marca, :btus, :local_instalacao, presence: true
end
