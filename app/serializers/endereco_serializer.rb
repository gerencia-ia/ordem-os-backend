# frozen_string_literal: true

class EnderecoSerializer < ActiveModel::Serializer
  attributes :id, :rua, :numero, :bairro, :cidade, :complemento, :cep
end
