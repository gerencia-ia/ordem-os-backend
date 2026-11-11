# frozen_string_literal: true

class EquipamentoSerializer < ActiveModel::Serializer
  attributes :id, :marca, :btus, :inverter, :local_instalacao, :observacao, :cliente_id
end
