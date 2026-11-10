# frozen_string_literal: true

class HistoricoLaudoSerializer < ActiveModel::Serializer
  attributes :id, :laudo, :created_at, :updated_at, :ordem_servico

  def ordem_servico
    os = object.ordem_servico
    return nil unless os

    {
      id: os.id,
      numero_ordem: os.numero_ordem,
      descricao: os.descricao,
      data_agendamento: os.data_agendamento,
      data_fechamento: os.data_fim_atendimento,
      status: os.status&.nome,
      prioridade: os.prioridade&.descricao
    }
  end
end
