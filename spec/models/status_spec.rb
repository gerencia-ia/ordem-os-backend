# frozen_string_literal: true

require "rails_helper"

RSpec.describe Status, type: :model do
  describe "validações" do
    it "é válido com nome" do
      status = Status.new(nome: "Pendente")
      expect(status).to be_valid
    end

    it "exige nome e normaliza espaços" do
      s = Status.create!(nome: "   Em Análise   ")
      expect(s.nome).to eq("Em Análise")
    end

    it "exige unicidade do nome" do
      Status.create!(nome: "Finalizada")
      duplicado = Status.new(nome: "finalizada")
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:nome]).to be_present
    end
  end
end
