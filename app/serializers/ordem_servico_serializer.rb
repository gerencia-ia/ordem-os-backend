# frozen_string_literal: true

class OrdemServicoSerializer < ActiveModel::Serializer
  attributes :id, :numero_ordem, :descricao,
             :status, :prioridade, :data_agendamento, 
             :data_fechamento, :data_vencimento,
             :data_inicio_atendimento, :data_fim_atendimento,
             :observacao, :custo_estimado, :valor_total,
             :cliente, :endereco, :tecnicos, :servicos, :equipamentos,
             :created_at, :updated_at

  def status
    s = object.status
    return nil unless s

    {
      id: s.id,
      nome: s.nome,
    }
  end

  def prioridade
    p = object.prioridade
    return nil unless p

    {
      id: p.id,
      nome: p.descricao,
    }
  end

  def cliente
    c = object.cliente
    return nil unless c

    {
      id: c.id,
      nome: c.nome,
      email: c.try(:email),
      telefones: c.respond_to?(:telefones) ? c.telefones.map { |t| { id: t.id, numero: t.numero, tipo: t.try(:tipo) } } : [],
      enderecos: c.respond_to?(:enderecos) ? c.enderecos.map { |e| { id: e.id, rua: e.try(:rua), numero: e.try(:numero), bairro: e.try(:bairro), cidade: e.try(:cidade), complemento: e.try(:complemento), cep: e.try(:cep) } } : []
    }
  end

  def endereco
    e = object.endereco
    return nil unless e

    {
      id: e.id,
      rua: e.try(:rua),
      numero: e.try(:numero),
      bairro: e.try(:bairro),
      cidade: e.try(:cidade),
      complemento: e.try(:complemento),
      cep: e.try(:cep)
    }
  end

  def tecnicos
    # Considera o primeiro técnico relacionado como responsável, se houver
    t = object.users&.first
    return nil unless t
    {
      id: t.id,
      nome: t.nome,
      cpf: t.try(:cpf),
      email: t.try(:email),
      telefone: t.try(:telefone),
      role: t.role ? { id: t.role.id, nome: t.role.nome } : nil
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
end
