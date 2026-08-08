# frozen_string_literal: true

class Tecnico < ApplicationRecord
  has_many :os_tecnicos, foreign_key: :tecnico_id, dependent: :destroy, inverse_of: :tecnico
  has_many :ordem_servicos, through: :os_tecnicos, source: :ordem_servico
  has_many :tarefas, foreign_key: :tecnico_id, dependent: :nullify, inverse_of: :tecnico

  validates :nome, :telefone, :especialidades, presence: true
  validates :cpf, presence: true, uniqueness: true
end
