# frozen_string_literal: true

require "rails_helper"

RSpec.describe Telefone, type: :model do
  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Tel",
      enderecos_attributes: [ { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41999998888" } ]
    )
  end

  describe "validações e normalização" do
    it "é válido com 10 dígitos (telefone fixo)" do
      telefone = cliente.telefones.build(numero: "(11) 3322-4455")
      expect(telefone).to be_valid
      expect(telefone.numero).to eq("1133224455")
    end

    it "é válido com 11 dígitos (celular com nono dígito)" do
      telefone = cliente.telefones.build(numero: "(11) 98888-7777")
      expect(telefone).to be_valid
      expect(telefone.numero).to eq("11988887777")
    end

    it "é inválido com menos de 10 dígitos" do
      telefone = cliente.telefones.build(numero: "1234567")
      expect(telefone).not_to be_valid
      expect(telefone.errors[:numero]).to include("deve conter DDD + 8 ou 9 dígitos")
    end

    it "é inválido com mais de 11 dígitos" do
      telefone = cliente.telefones.build(numero: "551198888777799")
      expect(telefone).not_to be_valid
      expect(telefone.errors[:numero]).to include("deve conter DDD + 8 ou 9 dígitos")
    end
  end
end
