# frozen_string_literal: true

require "securerandom"

class OrdemServico < ApplicationRecord
  normalizes :descricao, :observacao, with: ->(s) { s&.strip }

  belongs_to :status, inverse_of: :ordem_servicos
  belongs_to :prioridade, inverse_of: :ordem_servicos
  belongs_to :cliente, inverse_of: :ordem_servicos
  belongs_to :endereco, optional: true, inverse_of: :ordem_servicos

  has_many :os_tecnicos, dependent: :destroy, inverse_of: :ordem_servico
  has_many :users, through: :os_tecnicos, source: :user

  has_many :os_servicos, dependent: :destroy, inverse_of: :ordem_servico
  has_many :servicos, through: :os_servicos, source: :servico
  has_many :os_materiais, dependent: :destroy, inverse_of: :ordem_servico
  has_many :materiais, through: :os_materiais, source: :material
  accepts_nested_attributes_for :os_materiais, allow_destroy: true

  has_many :os_equipamentos, dependent: :destroy, inverse_of: :ordem_servico
  has_many :equipamentos, through: :os_equipamentos, source: :equipamento
  accepts_nested_attributes_for :os_equipamentos, allow_destroy: true

  has_many :tarefas, dependent: :destroy, inverse_of: :ordem_servico

  before_validation :generate_numero_ordem, on: :create

  validates :status_id, :prioridade_id, :cliente_id, presence: true
  validates :endereco_id, presence: true, on: :create
  validates :numero_ordem, presence: true, uniqueness: true
  validates :valor_total, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :custo_estimado, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :endereco_deve_pertencer_ao_cliente, if: -> { endereco_id.present? && cliente_id.present? }
  validate :data_vencimento_nao_pode_ser_anterior_ao_agendamento
  validate :data_fechamento_nao_pode_ser_anterior_ao_agendamento
  validate :data_fim_atendimento_nao_pode_ser_anterior_ao_inicio

  scope :por_mes_e_ano, ->(mes, ano) {
    where("EXTRACT(MONTH FROM data_agendamento) = ? AND EXTRACT(YEAR FROM data_agendamento) = ?", mes.to_i, ano.to_i)
  }
  scope :por_cliente, ->(cliente_id) { where(cliente_id: cliente_id) }
  scope :recentes, -> { order(created_at: :desc) }

  def recalcular_valor_total!
    total = os_servicos.includes(:servico).sum do |item|
      (item.quantidade || 1) * (item.servico&.valor || 0)
    end
    update!(valor_total: total)
  end

  private

  def generate_numero_ordem
    return if numero_ordem.present?

    loop do
      codigo = "OS-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.alphanumeric(4).upcase}"
      unless self.class.exists?(numero_ordem: codigo)
        self.numero_ordem = codigo
        break
      end
    end
  end

  def endereco_deve_pertencer_ao_cliente
    return if cliente.blank? || endereco.blank?
    return if endereco.cliente_id == cliente_id

    errors.add(:endereco_id, "deve pertencer ao mesmo cliente da ordem de servico")
  end

  def data_vencimento_nao_pode_ser_anterior_ao_agendamento
    return if data_agendamento.blank? || data_vencimento.blank?

    if data_vencimento < data_agendamento.to_date
      errors.add(:data_vencimento, "não pode ser anterior à data de agendamento")
    end
  end

  def data_fechamento_nao_pode_ser_anterior_ao_agendamento
    return if data_agendamento.blank? || data_fechamento.blank?

    if data_fechamento < data_agendamento.to_date
      errors.add(:data_fechamento, "não pode ser anterior à data de agendamento")
    end
  end

  def data_fim_atendimento_nao_pode_ser_anterior_ao_inicio
    return if data_inicio_atendimento.blank? || data_fim_atendimento.blank?

    if data_fim_atendimento < data_inicio_atendimento
      errors.add(:data_fim_atendimento, "não pode ser anterior à data de início de atendimento")
    end
  end
end
