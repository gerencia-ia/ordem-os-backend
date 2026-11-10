# frozen_string_literal: true

class OsServico < ApplicationRecord
  belongs_to :ordem_servico, foreign_key: :ordem_servico_id, inverse_of: :os_servicos
  belongs_to :servico, foreign_key: :servico_id, inverse_of: :os_servicos

  validates :servico, :ordem_servico, presence: true

  before_validation :registrar_dados_do_catalogo, on: :create

  private

  def registrar_dados_do_catalogo
    return unless servico

    self.nome_servico ||= servico.nome
    self.valor_unitario ||= servico.valor
  end
end
