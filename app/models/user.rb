class User < ApplicationRecord
  has_secure_password
  has_one :tecnico, foreign_key: "cpf", primary_key: "cpf"
  belongs_to :role

  validates :cpf, presence: true, uniqueness: true
end
