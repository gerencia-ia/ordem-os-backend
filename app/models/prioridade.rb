# frozen_string_literal: true

class Prioridade < ApplicationRecord
  normalizes :descricao, with: ->(d) { d.to_s.strip }

  has_many :ordem_servicos, dependent: :restrict_with_error, inverse_of: :prioridade

  validates :descricao, presence: true, uniqueness: { case_sensitive: false }
end
