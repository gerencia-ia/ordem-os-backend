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
    object.os_servicos
  end

  def equipamentos
    object.os_equipamentos
  end
end
