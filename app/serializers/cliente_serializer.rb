# frozen_string_literal: true

class ClienteSerializer < ActiveModel::Serializer
  attributes :id, :nome, :email, :data_registro, :data_ultima_visita

  has_many :telefones
  has_many :enderecos
end
