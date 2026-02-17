# frozen_string_literal: true

class OrdemServicoSerializer < ActiveModel::Serializer
  attributes :id, :numero_ordem, :descricao, :tipo_servico,
             :status_id, :status_descricao,
             :prioridade_id, :prioridade_descricao,
             :data_agendamento, :data_fechamento, :data_vencimento,
             :data_inicio_atendimento, :data_fim_atendimento,
             :created_at, :updated_at,
             :cliente_id, :cliente_nome, :observacao, :custo_estimado, :valor_total, :notas,
             :cliente, :tecnico_responsavel, :servicos, :equipamentos

  def status_descricao
    object.status&.nome
  end

  def prioridade_descricao
    object.prioridade&.descricao
  end

  def cliente_nome
    object.cliente&.nome
  end

  def cliente
    c = object.cliente
    return nil unless c
    {
      id: c.id,
      nome: c.nome,
      email: c.try(:email),
      telefones: c.respond_to?(:telefones) ? c.telefones.map { |t| { id: t.id, numero: t.numero, tipo: t.try(:tipo) } } : [],
      enderecos: c.respond_to?(:enderecos) ? c.enderecos.map { |e| { id: e.id, rua: e.try(:rua), numero: e.try(:numero), bairro: e.try(:bairro), cidade: e.try(:cidade), complemento: e.try(:complemento) } } : []
    }
  end

  def tecnico_responsavel
    # Considera o primeiro técnico relacionado como responsável, se houver
    t = object.tecnicos&.first
    return nil unless t
    {
      id: t.id,
      nome: t.nome,
      email: t.try(:email),
      telefone: t.try(:telefone),
      especialidades: t.try(:especialidades),
      status_disponibilidade: t.try(:status_disponibilidade)
    }
  end
 def servicos
    object.servicos.includes(:categorias_servico).map do |s|
      {
        id: s.id,
        nome: s.try(:nome),
        valor: s.try(:valor),
        tempo_servico: s.try(:tempo_servico),
        categoria: s.categorias_servico ? {
          id: s.categorias_servico.id,
          descricao: s.categorias_servico.descricao
        } : nil
      }
    end
  end
  def equipamentos
    object.os_equipamentos.includes(:equipamento).map do |oe|
      e = oe.equipamento
      {
        id: e&.id,
        marca: e.try(:marca),
        btus: e.try(:btus),
        local_instalacao: e.try(:local_instalacao),
        laudo: oe.laudo
      }
    end
  end

  def notas
    object.try(:notas)
  end
end
