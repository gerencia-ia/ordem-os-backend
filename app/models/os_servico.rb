# frozen_string_literal: true

class OsServico < ApplicationRecord
  belongs_to :ordem_servico, inverse_of: :os_servicos
  belongs_to :valor_por_andar, inverse_of: :os_servicos
  belongs_to :equipamento, inverse_of: :os_servicos

  has_one :servico, through: :valor_por_andar
  has_one :andar, through: :valor_por_andar

  before_validation :set_default_quantidade
  before_validation :registrar_dados_do_catalogo, on: :create

  validates :ordem_servico, :valor_por_andar, :equipamento, presence: true
  validates :valor_por_andar_id, uniqueness: {
    scope: [ :ordem_servico_id, :equipamento_id ],
    message: "já está adicionado para este equipamento nesta ordem de serviço"
  }
  validates :quantidade, numericality: { greater_than: 0 }

  private

  def registrar_dados_do_catalogo
    return unless valor_por_andar

    self.nome_servico ||= valor_por_andar.servico&.nome
    self.valor_unitario ||= valor_por_andar.valor
  end

  def set_default_quantidade
    self.quantidade ||= 1
  end
end
