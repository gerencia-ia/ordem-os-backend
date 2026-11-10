# frozen_string_literal: true

class Tarefa < ApplicationRecord
  normalizes :descricao, with: ->(d) { d.to_s.strip }

  belongs_to :ordem_servico, inverse_of: :tarefas
  belongs_to :user, optional: true, inverse_of: :tarefas
  belongs_to :status, inverse_of: :tarefas

  validates :descricao, presence: true
  validate :data_fim_nao_pode_ser_anterior_a_data_inicio

  private

  def data_fim_nao_pode_ser_anterior_a_data_inicio
    return if data_inicio.blank? || data_fim.blank?

    if data_fim < data_inicio
      errors.add(:data_fim, "não pode ser anterior à data de início")
    end
  end
end
