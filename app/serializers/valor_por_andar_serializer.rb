# frozen_string_literal: true

class ValorPorAndarSerializer < ActiveModel::Serializer
  attributes :id, :servico_id, :andar_id, :valor, :andar

  def andar
    return nil unless object.andar

    {
      id: object.andar.id,
      descricao: object.andar.descricao
    }
  end
end
