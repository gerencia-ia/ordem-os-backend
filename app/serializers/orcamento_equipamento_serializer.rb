# frozen_string_literal: true

class OrcamentoEquipamentoSerializer < ActiveModel::Serializer
  attributes :id, :equipamento_id, :marca, :btus, :local_instalacao, :observacao, :andar_id, :andar

  def id
    object.equipamento_id
  end

  def equipamento_id
    object.equipamento_id
  end

  def marca
    object.equipamento&.marca
  end

  def btus
    object.equipamento&.btus
  end

  def local_instalacao
    object.equipamento&.local_instalacao
  end

  def observacao
    object.equipamento&.observacao
  end

  def andar_id
    object.equipamento&.andar_id
  end

  def andar
    andar = object.equipamento&.andar
    return nil unless andar

    {
      id: andar.id,
      descricao: andar.descricao
    }
  end
end
