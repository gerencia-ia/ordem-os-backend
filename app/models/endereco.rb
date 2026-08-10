# frozen_string_literal: true

class Endereco < ApplicationRecord
  belongs_to :cliente, foreign_key: :cliente_id, inverse_of: :enderecos
  has_many :ordem_servicos, foreign_key: :endereco_id, dependent: :nullify, inverse_of: :endereco

  validates :rua, :numero, :bairro, :cidade, :cliente, presence: true
end
