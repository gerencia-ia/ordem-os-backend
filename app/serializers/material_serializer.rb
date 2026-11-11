# frozen_string_literal: true

class MaterialSerializer < ActiveModel::Serializer
  attributes :id, :nome, :descricao, :valor_referencia
end
