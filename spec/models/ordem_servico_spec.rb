# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrdemServico, type: :model do
  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente OS",
      enderecos_attributes: [
        { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba", cep: "80010000" }
      ],
      telefones_attributes: [ { numero: "41999998888" } ]
    )
  end
  let!(:outro_cliente) do
    Cliente.create!(
      nome: "Outro Cliente",
      enderecos_attributes: [
        { rua: "Rua B", numero: "20", bairro: "Batel", cidade: "Curitiba", cep: "80420000" }
      ],
      telefones_attributes: [ { numero: "41977776666" } ]
    )
  end

  let!(:prioridade) { Prioridade.create!(descricao: "Alta") }
  let!(:status) { Status.create!(nome: "Aberta") }

  describe "geração automática de numero_ordem" do
    it "gera automaticamente no formato OS-YYYYMMDD-XXXX quando não informado" do
      os = OrdemServico.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )

      expect(os.numero_ordem).to be_present
      expect(os.numero_ordem).to match(/^OS-\d{8}-[A-Z0-9]{4}$/)
    end

    it "preserva numero_ordem se for explicitamente fornecido" do
      os = OrdemServico.create!(
        numero_ordem: "OS-CUSTOM-2026",
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )

      expect(os.numero_ordem).to eq("OS-CUSTOM-2026")
    end

    it "exige unicidade do numero_ordem" do
      OrdemServico.create!(
        numero_ordem: "OS-UNICA-01",
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )

      os_duplicada = OrdemServico.new(
        numero_ordem: "OS-UNICA-01",
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )

      expect(os_duplicada).not_to be_valid
      expect(os_duplicada.errors[:numero_ordem]).to be_present
    end
  end

  describe "validações de integridade e cliente" do
    it "impede que a OS use um endereço de outro cliente" do
      os = OrdemServico.new(
        cliente: cliente,
        endereco: outro_cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )

      expect(os).not_to be_valid
      expect(os.errors[:endereco_id]).to include("deve pertencer ao mesmo cliente da ordem de servico")
    end

    it "exige cliente, status, prioridade e endereco na criação" do
      os = OrdemServico.new
      expect(os).not_to be_valid
      expect(os.errors[:cliente_id]).to be_present
      expect(os.errors[:status_id]).to be_present
      expect(os.errors[:prioridade_id]).to be_present
      expect(os.errors[:endereco_id]).to be_present
    end
  end

  describe "validações numéricas" do
    it "rejeita valores monetários negativos" do
      os = OrdemServico.new(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status,
        valor_total: -50.0,
        custo_estimado: -10.0
      )

      expect(os).not_to be_valid
      expect(os.errors[:valor_total]).to be_present
      expect(os.errors[:custo_estimado]).to be_present
    end
  end

  describe "validações cronológicas de data" do
    it "rejeita data_vencimento anterior a data_agendamento" do
      os = OrdemServico.new(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status,
        data_agendamento: Time.zone.parse("2026-11-20 09:00:00"),
        data_vencimento: Date.parse("2026-11-15")
      )

      expect(os).not_to be_valid
      expect(os.errors[:data_vencimento]).to include("não pode ser anterior à data de agendamento")
    end

    it "rejeita data_fim_atendimento anterior a data_inicio_atendimento" do
      os = OrdemServico.new(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status,
        data_inicio_atendimento: Time.zone.parse("2026-11-20 14:00:00"),
        data_fim_atendimento: Time.zone.parse("2026-11-20 13:00:00")
      )

      expect(os).not_to be_valid
      expect(os.errors[:data_fim_atendimento]).to include("não pode ser anterior à data de início de atendimento")
    end
  end

  describe "#recalcular_valor_total!" do
    let!(:servico1) { Servico.create!(nome: "Carga Gás", valor: 200.0) }
    let!(:servico2) { Servico.create!(nome: "Higienização", valor: 150.0) }

    it "recalcula a soma com base nos itens de serviço vinculados" do
      os = OrdemServico.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )

      os.os_servicos.create!(servico: servico1, quantidade: 2) # 400.0
      os.os_servicos.create!(servico: servico2, quantidade: 1) # 150.0

      os.recalcular_valor_total!
      expect(os.reload.valor_total).to eq(550.0)
    end
  end

  describe "scopes" do
    let!(:os1) do
      OrdemServico.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status,
        data_agendamento: Time.zone.parse("2026-05-10 10:00:00")
      )
    end
    let!(:os2) do
      OrdemServico.create!(
        cliente: outro_cliente,
        endereco: outro_cliente.enderecos.first,
        prioridade: prioridade,
        status: status,
        data_agendamento: Time.zone.parse("2026-06-15 10:00:00")
      )
    end

    it "filtra por cliente" do
      expect(OrdemServico.por_cliente(cliente.id)).to include(os1)
      expect(OrdemServico.por_cliente(cliente.id)).not_to include(os2)
    end

    it "filtra por mês e ano do agendamento" do
      expect(OrdemServico.por_mes_e_ano(5, 2026)).to include(os1)
      expect(OrdemServico.por_mes_e_ano(5, 2026)).not_to include(os2)
    end
  end
end
