# frozen_string_literal: true

class OrcamentoMaterialSerializer < ActiveModel::Serializer
  attributes :id, :material_id, :nome, :valor

  def nome
    object.nome_material
  end
end
