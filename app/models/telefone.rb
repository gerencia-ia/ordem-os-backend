# frozen_string_literal: true

class Telefone < ApplicationRecord
  belongs_to :cliente, foreign_key: :cliente_id, inverse_of: :telefones

  validates :numero, presence: true
end
