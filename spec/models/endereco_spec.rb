# frozen_string_literal: true

require "rails_helper"

RSpec.describe Endereco, type: :model do
  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Teste",
      enderecos_attributes: [ { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41999998888" } ]
    )
  end

  describe "validações" do
    it "é válido com dados obrigatórios preenchidos" do
      endereco = cliente.enderecos.build(
        rua: "Av. Brasil",
        numero: "500",
        bairro: "Jardins",
        cidade: "São Paulo",
        cep: "01430000"
      )
      expect(endereco).to be_valid
    end

    it "exige rua, numero, bairro e cidade" do
      endereco = cliente.enderecos.build
      expect(endereco).not_to be_valid
      expect(endereco.errors[:rua]).to be_present
      expect(endereco.errors[:numero]).to be_present
      expect(endereco.errors[:bairro]).to be_present
      expect(endereco.errors[:cidade]).to be_present
    end

    it "valida que o CEP deve conter exatamente 8 dígitos numéricos se preenchido" do
      endereco = cliente.enderecos.build(
        rua: "Rua B",
        numero: "20",
        bairro: "Bairro",
        cidade: "Cidade",
        cep: "123"
      )
      expect(endereco).not_to be_valid
      expect(endereco.errors[:cep]).to include("deve conter 8 dígitos numéricos")
    end
  end

  describe "normalizações" do
    it "sanitiza CEP removendo traços e espaços" do
      endereco = cliente.enderecos.create!(
        rua: "  Rua das Acácias  ",
        numero: "100",
        bairro: "Centro",
        cidade: "São Paulo",
        cep: " 01.310-100 "
      )
      expect(endereco.cep).to eq("01310100")
      expect(endereco.rua).to eq("Rua das Acácias")
    end
  end

  describe "#endereco_completo" do
    it "formata adequadamente a string de endereço" do
      endereco = cliente.enderecos.build(
        rua: "Av. Paulista",
        numero: "1000",
        complemento: "Conj 42",
        bairro: "Bela Vista",
        cidade: "São Paulo",
        cep: "01310100"
      )
      expect(endereco.endereco_completo).to eq("Av. Paulista, 1000 - Conj 42 - Bela Vista - São Paulo - CEP: 01310100")
    end
  end
end
