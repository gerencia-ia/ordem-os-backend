# frozen_string_literal: true

class EquipamentoSerializer < ActiveModel::Serializer
  attributes :id, :marca, :btus, :local_instalacao, :observacao, :cliente_id, :andar_id

  belongs_to :andar
end
