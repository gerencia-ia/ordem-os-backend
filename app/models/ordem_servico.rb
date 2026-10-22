# frozen_string_literal: true

class OrdemServico < ApplicationRecord
  belongs_to :status, foreign_key: :status_id, inverse_of: :ordem_servicos
  belongs_to :prioridade, foreign_key: :prioridade_id, inverse_of: :ordem_servicos
  belongs_to :cliente, foreign_key: :cliente_id, inverse_of: :ordem_servicos
  belongs_to :endereco, foreign_key: :endereco_id, optional: true, inverse_of: :ordem_servicos

  has_many :os_tecnicos, foreign_key: :ordem_servico_id, dependent: :destroy, inverse_of: :ordem_servico
  has_many :users, through: :os_tecnicos, source: :user

  has_many :os_servicos, foreign_key: :ordem_servico_id, dependent: :destroy, inverse_of: :ordem_servico
  has_many :servicos, through: :os_servicos, source: :servico

  has_many :os_equipamentos, foreign_key: :ordem_servico_id, dependent: :destroy, inverse_of: :ordem_servico
  has_many :equipamentos, through: :os_equipamentos, source: :equipamento
  accepts_nested_attributes_for :os_equipamentos, allow_destroy: true

  has_many :tarefas, foreign_key: :ordem_servico_id, dependent: :destroy, inverse_of: :ordem_servico

  validates :status_id, :prioridade_id, :cliente_id, presence: true
  validates :endereco_id, presence: true, on: :create
  validate :endereco_deve_pertencer_ao_cliente, if: -> { endereco_id.present? && cliente_id.present? }

  private

  def endereco_deve_pertencer_ao_cliente
    return if cliente.blank? || endereco.blank?
    return if endereco.cliente_id == cliente_id

    errors.add(:endereco_id, "deve pertencer ao mesmo cliente da ordem de servico")
  end
end
