# frozen_string_literal: true

class ServicoSerializer < ActiveModel::Serializer
  attributes :id, :nome, :tempo_servico

  belongs_to :categorias_servico
  has_many :valores_por_andares, serializer: ValorPorAndarSerializer
end
