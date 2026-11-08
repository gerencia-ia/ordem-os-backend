# frozen_string_literal: true

require "rails_helper"

RSpec.describe Servico, type: :model do
  let(:categoria) { CategoriasServico.create!(descricao: "Preventiva") }

  describe "validações" do
    it "é válido com atributos corretos" do
      servico = Servico.new(
        nome: "Limpeza de Filtros",
        valor: 150.0,
        tempo_servico: 45,
        categorias_servico: categoria
      )
      expect(servico).to be_valid
    end

    it "exige nome e valor" do
      servico = Servico.new
      expect(servico).not_to be_valid
      expect(servico.errors[:nome]).to be_present
      expect(servico.errors[:valor]).to be_present
    end

    it "valida que valor não pode ser negativo" do
      servico = Servico.new(nome: "Troca", valor: -10)
      expect(servico).not_to be_valid
      expect(servico.errors[:valor]).to be_present
    end

    it "valida que tempo_servico deve ser número inteiro não-negativo" do
      servico = Servico.new(nome: "Carga", valor: 100, tempo_servico: -5)
      expect(servico).not_to be_valid
      expect(servico.errors[:tempo_servico]).to be_present
    end

    it "exige unicidade do nome (case-insensitive)" do
      Servico.create!(nome: "Vácuo no Sistema", valor: 80.0)
      duplicado = Servico.new(nome: "vácuo no sistema", valor: 85.0)
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:nome]).to be_present
    end
  end

  describe "integridade relacional" do
    let!(:cliente) do
      Cliente.create!(
        nome: "Cliente Servico",
        enderecos_attributes: [ { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba" } ],
        telefones_attributes: [ { numero: "41999998888" } ]
      )
    end
    let!(:prioridade) { Prioridade.create!(descricao: "Baixa") }
    let!(:status) { Status.create!(nome: "Aberta") }
    let!(:servico) { Servico.create!(nome: "Instalação Split", valor: 450.0) }
    let!(:os) do
      OrdemServico.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        prioridade: prioridade,
        status: status
      )
    end

    it "impede a exclusão do serviço se vinculado a uma OS histórica" do
      os.os_servicos.create!(servico: servico, quantidade: 1)

      expect { servico.destroy }.not_to change(Servico, :count)
      expect(servico.errors[:base]).to be_present
    end
  end
end
