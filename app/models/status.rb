# frozen_string_literal: true

class Status < ApplicationRecord
  normalizes :nome, with: ->(n) { n.to_s.strip }

  has_many :ordem_servicos, dependent: :restrict_with_error, inverse_of: :status
  has_many :tarefas, dependent: :restrict_with_error, inverse_of: :status

  validates :nome, presence: true, uniqueness: { case_sensitive: false }
end
