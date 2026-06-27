# frozen_string_literal: true

class OrdemServico < ApplicationRecord
  belongs_to :status
  belongs_to :prioridade
  belongs_to :cliente
  belongs_to :endereco, optional: true
  
  has_many :os_tecnicos, dependent: :destroy
  has_many :tecnicos, through: :os_tecnicos
  
  has_many :os_servicos, dependent: :destroy
  has_many :servicos, through: :os_servicos
  
  has_many :os_equipamentos, dependent: :destroy
  has_many :equipamentos, through: :os_equipamentos
  accepts_nested_attributes_for :os_equipamentos, allow_destroy: true
  
  has_many :tarefas, dependent: :destroy
  
  validates :status_id, :prioridade_id, :cliente_id, presence: true
  validates :endereco_id, presence: true, on: :create
  validate :endereco_deve_pertencer_ao_cliente, if: -> { endereco_id.present? && cliente_id.present? }

  private

  def endereco_deve_pertencer_ao_cliente
    return if cliente.blank? || endereco.blank?
    return if endereco.cliente_id == cliente_id

    errors.add(:endereco_id, 'deve pertencer ao mesmo cliente da ordem de servico')
  end
end
