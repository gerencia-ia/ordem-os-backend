# frozen_string_literal: true

class Servico < ApplicationRecord
  normalizes :nome, with: ->(n) { n.to_s.strip }

  belongs_to :categorias_servico, optional: true, inverse_of: :servicos
  has_many :valores_por_andares, dependent: :restrict_with_error, inverse_of: :servico
  has_many :andares, through: :valores_por_andares, source: :andar
  has_many :os_servicos, through: :valores_por_andares
  has_many :ordem_servicos, through: :os_servicos, source: :ordem_servico

  validates :nome, presence: true, uniqueness: { case_sensitive: false }
  validates :tempo_servico, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
