# frozen_string_literal: true

class Tarefa < ApplicationRecord
  belongs_to :ordem_servico, foreign_key: :ordem_servico_id, inverse_of: :tarefas
  belongs_to :user, foreign_key: :user_id, optional: true, inverse_of: :tarefas

  validates :descricao, presence: true
end
