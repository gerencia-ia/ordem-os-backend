# frozen_string_literal: true

class OsEquipamentoSerializer < ActiveModel::Serializer
  attributes :id, :equipamento_id, :marca, :btus, :local_instalacao, :observacao, :laudo

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
end
