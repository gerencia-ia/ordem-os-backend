# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :nome, :email, :cpf, :telefone, :role_id

  belongs_to :role
end

