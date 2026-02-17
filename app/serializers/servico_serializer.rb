# frozen_string_literal: true

class ServicoSerializer < ActiveModel::Serializer
  attributes :id, :nome, :valor, :tempo_servico
  belongs_to :categorias_servico
end
