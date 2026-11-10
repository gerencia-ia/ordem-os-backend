# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tarefa, type: :model do
  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Tarefa",
      enderecos_attributes: [ { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41999998888" } ]
    )
  end
  let!(:prioridade) { Prioridade.create!(descricao: "Normal") }
  let!(:status_os) { Status.create!(nome: "Em Progresso") }
  let!(:status_tarefa) { Status.create!(nome: "A Fazer") }
  let!(:os) do
    OrdemServico.create!(
      cliente: cliente,
      endereco: cliente.enderecos.first,
      prioridade: prioridade,
      status: status_os
    )
  end

  describe "validações" do
    it "é válido com descrição, status e ordem de serviço" do
      tarefa = Tarefa.new(
        ordem_servico: os,
        status: status_tarefa,
        descricao: "Comprar capacitor 35uF"
      )
      expect(tarefa).to be_valid
    end

    it "exige status e ordem de serviço (alinhado com restrições NOT NULL do banco)" do
      tarefa = Tarefa.new(descricao: "Teste sem vínculos")
      expect(tarefa).not_to be_valid
      expect(tarefa.errors[:ordem_servico]).to be_present
      expect(tarefa.errors[:status]).to be_present
    end

    it "exige descrição" do
      tarefa = Tarefa.new(ordem_servico: os, status: status_tarefa, descricao: nil)
      expect(tarefa).not_to be_valid
      expect(tarefa.errors[:descricao]).to be_present
    end

    it "valida que data_fim não pode ser anterior a data_inicio" do
      tarefa = Tarefa.new(
        ordem_servico: os,
        status: status_tarefa,
        descricao: "Executar solda",
        data_inicio: Time.current,
        data_fim: 1.day.ago
      )
      expect(tarefa).not_to be_valid
      expect(tarefa.errors[:data_fim]).to include("não pode ser anterior à data de início")
    end
  end
end
