# frozen_string_literal: true

class ClienteSerializer < ActiveModel::Serializer
  attributes :id, :nome, :email, :data_registro, :data_ultima_visita, :created_at, :updated_at
end
