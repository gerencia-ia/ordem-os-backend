# frozen_string_literal: true

class OsServicoSerializer < ActiveModel::Serializer
  attributes :id, :servico_id, :nome, :valor, :tempo_servico, :quantidade, :categoria

  def id
    object.servico_id
  end

  def servico_id
    object.servico_id
  end

  def nome
    object.nome_servico.presence || object.servico&.nome
  end

  def valor
    object.valor_unitario || object.servico&.valor
  end

  def tempo_servico
    object.servico&.tempo_servico
  end

  def quantidade
    return nil unless object.quantidade

    object.quantidade.to_f == object.quantidade.to_i ? object.quantidade.to_i : object.quantidade.to_f
  end

  def categoria
    cat = object.servico&.categorias_servico
    return nil unless cat

    {
      id: cat.id,
      descricao: cat.descricao
    }
  end
end
