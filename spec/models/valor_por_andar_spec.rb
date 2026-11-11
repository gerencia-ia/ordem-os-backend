# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValorPorAndar, type: :model do
  let(:valid_attributes) do
    {
      valor: 10.5
    }
  end

  describe "validações" do
    it "é válido com atributos e associações válidas" do
      pending "Associe os registros pais obrigatórios em valid_attributes"
      record = described_class.new(valid_attributes)
      expect(record).to be_valid
    end

    it "exige preenchimento dos campos obrigatórios" do
      record = described_class.new
      expect(record).not_to be_valid
      expect(record.errors[:valor]).to be_present
    end
  end

  describe "associações" do
    it "pertence a servico" do
      association = described_class.reflect_on_association(:servico)
      expect(association&.macro).to eq(:belongs_to)
    end
    it "pertence a andar" do
      association = described_class.reflect_on_association(:andar)
      expect(association&.macro).to eq(:belongs_to)
    end
  end
end
