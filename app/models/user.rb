# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :os_tecnicos, inverse_of: :user
  has_many :tarefas, inverse_of: :user

  belongs_to :role

  validates :cpf, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true
end
