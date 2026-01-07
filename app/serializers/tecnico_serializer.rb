# frozen_string_literal: true

class TecnicoSerializer < ActiveModel::Serializer
  attributes :id, :nome, :telefone, :especialidades, :cpf, :email
end
