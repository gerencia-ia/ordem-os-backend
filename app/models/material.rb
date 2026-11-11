# frozen_string_literal: true

class Material < ApplicationRecord
  self.table_name = "materiais"

  normalizes :nome, :descricao, with: ->(value) { value&.strip }

  has_many :os_materiais, dependent: :nullify, inverse_of: :material

  validates :nome, presence: true
  validates :valor_referencia, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
