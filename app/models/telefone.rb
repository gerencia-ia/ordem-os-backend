# frozen_string_literal: true

class Telefone < ApplicationRecord
  normalizes :numero, with: ->(n) { n.to_s.gsub(/\D/, "") }

  belongs_to :cliente, inverse_of: :telefones

  validates :numero, presence: true, length: { in: 10..11, message: "deve conter DDD + 8 ou 9 dígitos" }
end
