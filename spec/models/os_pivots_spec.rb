# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tabelas Pivô de Ordem de Serviço", type: :model do
  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Pivô",
      enderecos_attributes: [ { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41999998888" } ]
    )
  end
  let!(:outro_cliente) do
    Cliente.create!(
      nome: "Outro Cliente Pivô",
      enderecos_attributes: [ { rua: "Rua B", numero: "20", bairro: "Batel", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41977776666" } ]
    )
  end

  let!(:prioridade) { Prioridade.create!(descricao: "Média") }
  let!(:status) { Status.create!(nome: "Aberta") }
  let!(:role_tecnico) { Role.find_or_create_by!(nome: "Tecnico") }

  let!(:os) do
    OrdemServico.create!(
      cliente: cliente,
      endereco: cliente.enderecos.first,
      prioridade: prioridade,
      status: status
    )
  end

  describe OsEquipamento do
    let!(:equip_cliente) { cliente.equipamentos.create!(marca: "Daikin", local_instalacao: "Quarto") }
    let!(:equip_outro_cliente) { outro_cliente.equipamentos.create!(marca: "Gree", local_instalacao: "Sala") }

    it "impede adicionar equipamento de outro cliente à OS" do
      os_equip = os.os_equipamentos.build(equipamento: equip_outro_cliente)
      expect(os_equip).not_to be_valid
      expect(os_equip.errors[:equipamento_id]).to include("deve pertencer ao mesmo cliente da ordem de serviço")
    end

    it "impede vincular o mesmo equipamento mais de uma vez na mesma OS" do
      os.os_equipamentos.create!(equipamento: equip_cliente)
      duplicado = os.os_equipamentos.build(equipamento: equip_cliente)
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:equipamento_id]).to include("já está vinculado a esta ordem de serviço")
    end
  end

  describe OsServico do
    let!(:servico) { Servico.create!(nome: "Troca Filtro", valor: 50.0) }

    it "define quantidade 1 por padrão se omitida" do
      os_serv = os.os_servicos.create!(servico: servico)
      expect(os_serv.quantidade).to eq(1)
    end

    it "impede quantidade menor ou igual a zero" do
      os_serv = os.os_servicos.build(servico: servico, quantidade: 0)
      expect(os_serv).not_to be_valid
      expect(os_serv.errors[:quantidade]).to be_present
    end

    it "impede duplicar o mesmo serviço na mesma OS" do
      os.os_servicos.create!(servico: servico, quantidade: 1)
      duplicado = os.os_servicos.build(servico: servico, quantidade: 2)
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:servico_id]).to include("já está adicionado a esta ordem de serviço")
    end
  end

  describe OsTecnico do
    let!(:tecnico) do
      User.create!(
        nome: "Técnico Silva",
        cpf: "11122233344",
        password: "password123",
        role: role_tecnico
      )
    end

    it "impede atribuir o mesmo técnico mais de uma vez à mesma OS" do
      os.os_tecnicos.create!(user: tecnico)
      duplicado = os.os_tecnicos.build(user: tecnico)
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:user_id]).to include("já está atribuído a esta ordem de serviço")
    end
  end
end
