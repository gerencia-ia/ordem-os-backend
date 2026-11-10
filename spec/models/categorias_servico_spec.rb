# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoriasServico, type: :model do
  describe "validações e normalização" do
    it "é válido com descrição" do
      cat = CategoriasServico.new(descricao: "Corretiva")
      expect(cat).to be_valid
    end

    it "exige descrição e normaliza espaços" do
      cat = CategoriasServico.create!(descricao: "   Manutenção Geral   ")
      expect(cat.descricao).to eq("Manutenção Geral")
    end

    it "exige unicidade da descrição" do
      CategoriasServico.create!(descricao: "Instalação")
      duplicada = CategoriasServico.new(descricao: "instalação")
      expect(duplicada).not_to be_valid
      expect(duplicada.errors[:descricao]).to be_present
    end
  end

  describe "integridade relacional" do
    let!(:categoria) { CategoriasServico.create!(descricao: "Elétrica") }
    let!(:servico) { Servico.create!(nome: "Troca de Disjuntor", valor: 120.0, categorias_servico: categoria) }

    it "impede exclusão se houver serviços associados" do
      expect { categoria.destroy }.not_to change(CategoriasServico, :count)
      expect(categoria.errors[:base]).to be_present
    end
  end
end
