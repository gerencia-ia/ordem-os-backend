# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cliente, type: :model do
  let(:valid_endereco_params) do
    { rua: "Rua das Flores", numero: "123", bairro: "Centro", cidade: "São Paulo", cep: "01001000" }
  end
  let(:valid_telefone_params) do
    { numero: "11988887777" }
  end

  describe "validações" do
    it "é válido com nome, ao menos um endereço e ao menos um telefone" do
      cliente = Cliente.new(
        nome: "Empresa Climatizada Ltda",
        email: "contato@climatizada.com",
        enderecos_attributes: [ valid_endereco_params ],
        telefones_attributes: [ valid_telefone_params ]
      )
      expect(cliente).to be_valid
    end

    it "exige a presença do nome" do
      cliente = Cliente.new(
        nome: nil,
        enderecos_attributes: [ valid_endereco_params ],
        telefones_attributes: [ valid_telefone_params ]
      )
      expect(cliente).not_to be_valid
      expect(cliente.errors[:nome]).to be_present
    end

    it "exige ao menos um endereço no cadastro inicial" do
      cliente = Cliente.new(
        nome: "Cliente Sem Endereço",
        telefones_attributes: [ valid_telefone_params ]
      )
      expect(cliente).not_to be_valid
      expect(cliente.errors[:enderecos]).to include("deve conter ao menos um endereço")
    end

    it "exige ao menos um telefone no cadastro inicial" do
      cliente = Cliente.new(
        nome: "Cliente Sem Telefone",
        enderecos_attributes: [ valid_endereco_params ]
      )
      expect(cliente).not_to be_valid
      expect(cliente.errors[:telefones]).to include("deve conter ao menos um telefone")
    end

    it "valida formato de email quando informado" do
      cliente = Cliente.new(
        nome: "Cliente",
        email: "invalido@",
        enderecos_attributes: [ valid_endereco_params ],
        telefones_attributes: [ valid_telefone_params ]
      )
      expect(cliente).not_to be_valid
      expect(cliente.errors[:email]).to be_present
    end
  end

  describe "normalizações e defaults" do
    it "sanitiza nome e e-mail via normalizes" do
      cliente = Cliente.create!(
        nome: "   Ar Condicionado Master   ",
        email: "   CONTATO@MASTER.COM   ",
        enderecos_attributes: [ valid_endereco_params ],
        telefones_attributes: [ valid_telefone_params ]
      )
      expect(cliente.nome).to eq("Ar Condicionado Master")
      expect(cliente.email).to eq("contato@master.com")
    end

    it "define data_registro automaticamente se vier em branco na criação" do
      cliente = Cliente.create!(
        nome: "Cliente Data",
        enderecos_attributes: [ valid_endereco_params ],
        telefones_attributes: [ valid_telefone_params ]
      )
      expect(cliente.data_registro).to be_present
    end
  end

  describe "associações e deleção em cascata" do
    let!(:cliente) do
      Cliente.create!(
        nome: "Cliente Deleção",
        enderecos_attributes: [ valid_endereco_params ],
        telefones_attributes: [ valid_telefone_params ],
        equipamentos_attributes: [ { marca: "LG", local_instalacao: "Sala 1" } ]
      )
    end

    it "apaga endereços, telefones e equipamentos quando o cliente é excluído" do
      expect {
        cliente.destroy
      }.to change(Endereco, :count).by(-1)
       .and change(Telefone, :count).by(-1)
       .and change(Equipamento, :count).by(-1)
    end
  end
end
