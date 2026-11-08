# frozen_string_literal: true

class Endereco < ApplicationRecord
  normalizes :cep, with: ->(c) { c.to_s.gsub(/\D/, "") }
  normalizes :rua, :numero, :bairro, :cidade, :complemento, with: ->(s) { s&.strip }

  belongs_to :cliente, inverse_of: :enderecos
  has_many :ordem_servicos, dependent: :restrict_with_error, inverse_of: :endereco

  validates :rua, :numero, :bairro, :cidade, presence: true
  validates :cep, length: { is: 8, message: "deve conter 8 dígitos numéricos" }, allow_blank: true

  def endereco_completo
    parts = [ "#{rua}, #{numero}" ]
    parts << complemento if complemento.present?
    parts << bairro if bairro.present?
    parts << cidade if cidade.present?
    parts << "CEP: #{cep}" if cep.present?
    parts.join(" - ")
  end
end
