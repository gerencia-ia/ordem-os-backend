# frozen_string_literal: true

class Andar < ApplicationRecord
  normalizes :descricao, with: ->(value) { value&.strip }

  has_many :equipamentos, dependent: :restrict_with_error, inverse_of: :andar
  has_many :valores_por_andares, dependent: :restrict_with_error, inverse_of: :andar

  validates :descricao, presence: true, uniqueness: { case_sensitive: false }
end
