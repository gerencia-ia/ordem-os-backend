# frozen_string_literal: true

class OrdemServicoSerializer < ActiveModel::Serializer
  attributes :id, :numero_ordem, :descricao,
             :data_agendamento, :data_fechamento, :data_vencimento,
             :data_inicio_atendimento, :data_fim_atendimento,
             :observacao, :custo_estimado, :valor_total,
             :created_at, :updated_at

  belongs_to :status
  belongs_to :prioridade
  belongs_to :cliente
  belongs_to :endereco

  has_many :tecnicos, serializer: UserSerializer
  has_one :tecnico_responsavel, serializer: UserSerializer
  has_many :servicos, serializer: OsServicoSerializer
  has_many :equipamentos, serializer: OsEquipamentoSerializer

  def tecnicos
    object.users
  end

  def tecnico_responsavel
    object.users.first
  end

  def servicos
    object.os_servicos.includes(servico: :categorias_servico).map do |os_servico|
      s = os_servico.servico
      {
        id: s.id,
        nome: os_servico.nome_servico.presence || s.try(:nome),
        descricao: os_servico.nome_servico.presence || s.try(:nome),
        valor: os_servico.valor_unitario || s.try(:valor),
        quantidade: os_servico.quantidade,
        tempo_servico: s.try(:tempo_servico),
        categoria: s.categorias_servico ? {
          id: s.categorias_servico.id,
          descricao: s.categorias_servico.descricao
        } : nil
      }
    end
  end

  def equipamentos
    object.os_equipamentos
  end
end
