# frozen_string_literal: true

class OrcamentoMaterial < ApplicationRecord
  self.table_name = "orcamento_materiais"

  belongs_to :orcamento, inverse_of: :orcamento_materiais
  belongs_to :material, optional: true, inverse_of: :orcamento_materiais

  before_validation :copiar_dados_do_catalogo

  validates :nome_material, presence: true
  validates :valor, numericality: { greater_than_or_equal_to: 0 }

  private

  def copiar_dados_do_catalogo
    return unless material

    self.nome_material = material.nome if nome_material.blank?
    self.valor = material.valor_referencia if valor.nil?
  end
end
