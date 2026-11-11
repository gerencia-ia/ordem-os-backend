# frozen_string_literal: true

require "rails_helper"

RSpec.describe Andar, type: :model do
  let(:valid_attributes) do
    {
      descricao: "Exemplo descricao"
    }
  end

  describe "validações" do
    it "é válido com atributos válidos" do
      record = described_class.new(valid_attributes)
      expect(record).to be_valid
    end

    it "exige preenchimento dos campos obrigatórios" do
      record = described_class.new
      expect(record).not_to be_valid
      expect(record.errors[:descricao]).to be_present
    end
  end

  describe "normalizações" do
    it "remove espaços em branco nas extremidades de strings" do
      record = described_class.new(descricao: "   Valor Teste   ")
      expect(record.descricao).to eq("Valor Teste")
    end
  end
end
