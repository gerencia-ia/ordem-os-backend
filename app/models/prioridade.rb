# frozen_string_literal: true

class Prioridade < ApplicationRecord
  has_many :ordem_servicos, foreign_key: :prioridade_id, dependent: :restrict_with_error, inverse_of: :prioridade

  validates :descricao, presence: true
end
