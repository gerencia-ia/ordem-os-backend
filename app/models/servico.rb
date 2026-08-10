# frozen_string_literal: true

class Servico < ApplicationRecord
  belongs_to :categorias_servico, foreign_key: :categorias_servico_id, optional: true, inverse_of: :servicos
  has_many :os_servicos, foreign_key: :servico_id, dependent: :destroy, inverse_of: :servico
  has_many :ordem_servicos, through: :os_servicos, source: :ordem_servico

  validates :nome, :valor, presence: true
end
