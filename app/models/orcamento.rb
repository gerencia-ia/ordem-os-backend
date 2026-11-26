# frozen_string_literal: true

require "securerandom"

class Orcamento < ApplicationRecord
  STATUSES = %w[rascunho enviado aprovado recusado expirado convertido].freeze
  STATUSES_EDITAVEIS = %w[rascunho enviado aprovado recusado expirado].freeze

  normalizes :condicoes_pagamento, :observacao, with: ->(s) { s&.strip }

  belongs_to :cliente, inverse_of: :orcamentos
  belongs_to :endereco, inverse_of: :orcamentos
  belongs_to :ordem_servico, optional: true, inverse_of: :orcamento

  has_many :orcamento_equipamentos, dependent: :destroy, inverse_of: :orcamento
  has_many :equipamentos, through: :orcamento_equipamentos, source: :equipamento

  has_many :orcamento_servicos, dependent: :destroy, inverse_of: :orcamento
  has_many :valores_por_andares, through: :orcamento_servicos, source: :valor_por_andar
  has_many :servicos, through: :valores_por_andares, source: :servico
  accepts_nested_attributes_for :orcamento_servicos, allow_destroy: true

  has_many :orcamento_materiais, dependent: :destroy, inverse_of: :orcamento
  has_many :materiais, through: :orcamento_materiais, source: :material
  accepts_nested_attributes_for :orcamento_materiais, allow_destroy: true

  before_validation :set_defaults
  before_validation :generate_numero_orcamento, on: :create
  before_save :calcular_totais

  validates :numero_orcamento, presence: true, uniqueness: true
  validates :cliente_id, :endereco_id, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :desconto, numericality: { greater_than_or_equal_to: 0 }

  validate :endereco_deve_pertencer_ao_cliente, if: -> { endereco_id.present? && cliente_id.present? }

  scope :por_cliente, ->(cliente_id) { where(cliente_id: cliente_id) }
  scope :por_status, ->(status) { where(status: status) }
  scope :por_mes_e_ano, ->(mes, ano) {
    where("EXTRACT(MONTH FROM created_at) = ? AND EXTRACT(YEAR FROM created_at) = ?", mes.to_i, ano.to_i)
  }
  scope :recentes, -> { order(created_at: :desc) }

  def convertido?
    status == "convertido"
  end

  def aprovado?
    status == "aprovado"
  end

  private

  def set_defaults
    self.status ||= "rascunho"
    self.desconto = 0 if desconto.nil?
  end

  def generate_numero_orcamento
    return if numero_orcamento.present?

    loop do
      codigo = "ORC-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.alphanumeric(4).upcase}"
      unless self.class.exists?(numero_orcamento: codigo)
        self.numero_orcamento = codigo
        break
      end
    end
  end

  def calcular_totais
    servicos_ativos = orcamento_servicos.reject(&:marked_for_destruction?)
    self.subtotal_servicos = servicos_ativos.sum do |item|
      valor = item.valor_unitario || item.valor_por_andar&.valor || 0
      (item.quantidade || 1) * valor
    end

    materiais_ativos = orcamento_materiais.reject(&:marked_for_destruction?)
    self.subtotal_materiais = materiais_ativos.sum { |item| item.valor || 0 }

    bruto = subtotal_servicos + subtotal_materiais
    self.valor_total = [ bruto - (desconto || 0), 0 ].max
  end

  def endereco_deve_pertencer_ao_cliente
    return if cliente.blank? || endereco.blank?
    return if endereco.cliente_id == cliente_id

    errors.add(:endereco_id, "deve pertencer ao mesmo cliente do orçamento")
  end
end
