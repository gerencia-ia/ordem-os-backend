# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_error, inverse_of: :role

  normalizes :nome, with: ->(n) { n.to_s.strip }

  validates :nome, presence: true, uniqueness: { case_sensitive: false }

  scope :administradores, -> { where("LOWER(nome) = ?", "administrador") }
  scope :tecnicos, -> { where("LOWER(nome) = ?", "tecnico") }
  scope :secretarias, -> { where("LOWER(nome) = ?", "secretaria") }
end
