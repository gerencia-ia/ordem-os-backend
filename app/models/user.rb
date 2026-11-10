# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  normalizes :nome, with: ->(n) { n.to_s.strip }
  normalizes :email, with: ->(e) { e.to_s.strip.downcase }
  normalizes :cpf, with: ->(c) { c.to_s.gsub(/\D/, "") }
  normalizes :telefone, with: ->(t) { t.to_s.gsub(/\D/, "") }

  belongs_to :role

  has_many :sessions, dependent: :destroy
  has_many :os_tecnicos, dependent: :restrict_with_error, inverse_of: :user
  has_many :ordem_servicos, through: :os_tecnicos, source: :ordem_servico
  has_many :tarefas, dependent: :nullify, inverse_of: :user

  validates :nome, presence: true
  validates :cpf, presence: true, uniqueness: { case_sensitive: false }, length: { is: 11, message: "deve conter 11 dígitos numéricos" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  scope :tecnicos, -> { joins(:role).where("LOWER(roles.nome) = ?", "tecnico") }
  scope :administradores, -> { joins(:role).where("LOWER(roles.nome) = ?", "administrador") }
  scope :secretarias, -> { joins(:role).where("LOWER(roles.nome) = ?", "secretaria") }

  def admin?
    role_slug == "administrador"
  end

  def secretaria?
    role_slug == "secretaria"
  end

  def tecnico?
    role_slug == "tecnico"
  end

  def role_slug
    role&.nome&.parameterize
  end
end
