# frozen_string_literal: true

class CategoriasServico < ApplicationRecord
  normalizes :descricao, with: ->(d) { d.to_s.strip }

  has_many :servicos, dependent: :restrict_with_error, inverse_of: :categorias_servico

  validates :descricao, presence: true, uniqueness: { case_sensitive: false }

  scope :ordenadas, -> { order(:descricao) }
end
