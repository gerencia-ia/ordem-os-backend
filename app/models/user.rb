# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :os_tecnicos, inverse_of: :user
  has_many :tarefas, inverse_of: :user

  belongs_to :role

  validates :cpf, presence: true, uniqueness: true

  before_validation :normalize_attributes

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

  private

  def normalize_attributes
    self.cpf = cpf.to_s.gsub(/\D/, "") if cpf.present?
    self.telefone = telefone.to_s.gsub(/\D/, "") if telefone.present?
  end
end
