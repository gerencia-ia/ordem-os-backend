# frozen_string_literal: true

class CategoriasServico < ApplicationRecord
  has_many :servicos, foreign_key: :categorias_servico_id, dependent: :restrict_with_error, inverse_of: :categorias_servico

  validates :descricao, presence: true, uniqueness: true
end
