# frozen_string_literal: true

require "rails_helper"

RSpec.describe Equipamento, type: :model do
  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Equipamento",
      enderecos_attributes: [ { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41999998888" } ]
    )
  end

  describe "validações" do
    it "é válido com marca e local de instalação" do
      equipamento = cliente.equipamentos.build(
        marca: "Fujitsu",
        local_instalacao: "Escritório 3",
        btus: "12000"
      )
      expect(equipamento).to be_valid
    end

    it "exige marca e local de instalação" do
      equipamento = cliente.equipamentos.build
      expect(equipamento).not_to be_valid
      expect(equipamento.errors[:marca]).to be_present
      expect(equipamento.errors[:local_instalacao]).to be_present
    end
  end

  describe "normalizações" do
    it "sanitiza strings removendo espaços extras" do
      equipamento = cliente.equipamentos.create!(
        marca: "   Carrier   ",
        local_instalacao: "   Recepção   "
      )
      expect(equipamento.marca).to eq("Carrier")
      expect(equipamento.local_instalacao).to eq("Recepção")
    end
  end

  describe "associações e integridade" do
    let!(:prioridade) { Prioridade.create!(descricao: "Média") }
    let!(:status) { Status.create!(nome: "Em Andamento") }
    let!(:equipamento) { cliente.equipamentos.create!(marca: "Daikin", local_instalacao: "Sala VIP") }
    let!(:os) do
      OrdemServico.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )
    end
    let!(:os_equipamento) do
      os.os_equipamentos.create!(equipamento: equipamento)
    end

    it "impede a exclusão do equipamento se houver ordens de serviço vinculadas" do
      expect { equipamento.destroy }.not_to change(Equipamento, :count)
      expect(equipamento.errors[:base]).to be_present
    end
  end
end
