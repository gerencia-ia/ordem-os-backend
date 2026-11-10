# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prioridade, type: :model do
  describe "validações" do
    it "é válido com descrição" do
      prioridade = Prioridade.new(descricao: "Urgente")
      expect(prioridade).to be_valid
    end

    it "exige descrição e normaliza espaços" do
      p = Prioridade.create!(descricao: "   Alta Prioridade   ")
      expect(p.descricao).to eq("Alta Prioridade")
    end

    it "exige unicidade da descrição" do
      Prioridade.create!(descricao: "Crítica")
      duplicada = Prioridade.new(descricao: "crítica")
      expect(duplicada).not_to be_valid
      expect(duplicada.errors[:descricao]).to be_present
    end
  end
end
