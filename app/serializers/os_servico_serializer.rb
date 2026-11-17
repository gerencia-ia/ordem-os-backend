# frozen_string_literal: true

class OsServicoSerializer < ActiveModel::Serializer
  attributes :id, :servico_id, :equipamento_id, :valor_por_andar_id, :nome, :valor, :tempo_servico, :quantidade, :categoria, :andar

  def id
    object.id
  end

  def servico_id
    object.valor_por_andar&.servico_id
  end

  def equipamento_id
    object.equipamento_id
  end

  def valor_por_andar_id
    object.valor_por_andar_id
  end

  def andar
    a = object.valor_por_andar&.andar
    return nil unless a

    {
      id: a.id,
      descricao: a.descricao
    }
  end

  def nome
    object.nome_servico.presence || object.servico&.nome
  end

  def valor
    object.valor_unitario || object.valor_por_andar&.valor
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
