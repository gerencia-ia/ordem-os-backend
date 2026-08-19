# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :ordem_servicos, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :status
  has_many :tarefas, foreign_key: :status_id, dependent: :restrict_with_error, inverse_of: :status

  validates :nome, presence: true
end
