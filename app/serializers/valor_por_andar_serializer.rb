# frozen_string_literal: true

class ValorPorAndarSerializer < ActiveModel::Serializer
  attributes :id, :servico_id, :andar_id, :valor
end
