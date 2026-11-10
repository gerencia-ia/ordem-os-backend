# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let(:role_tecnico) { Role.find_or_create_by!(nome: "Tecnico") }

  describe "validações" do
    it "é válido com atributos corretos" do
      user = User.new(
        nome: "Gabriel",
        cpf: "123.456.789-01",
        email: "gabriel@teste.com",
        telefone: "(11) 98888-7777",
        password: "password123",
        role: role_tecnico
      )
      expect(user).to be_valid
    end

    it "exige nome" do
      user = User.new(nome: nil, cpf: "12345678901", password: "password123", role: role_tecnico)
      expect(user).not_to be_valid
      expect(user.errors[:nome]).to be_present
    end

    it "exige cpf" do
      user = User.new(nome: "Teste", cpf: nil, password: "password123", role: role_tecnico)
      expect(user).not_to be_valid
      expect(user.errors[:cpf]).to be_present
    end

    it "valida que cpf deve conter exatamente 11 dígitos numéricos" do
      user = User.new(nome: "Teste", cpf: "12345", password: "password123", role: role_tecnico)
      expect(user).not_to be_valid
      expect(user.errors[:cpf]).to include("deve conter 11 dígitos numéricos")
    end

    it "exige unicidade de cpf" do
      User.create!(nome: "User 1", cpf: "11122233344", password: "password123", role: role_admin)
      user2 = User.new(nome: "User 2", cpf: "111.222.333-44", password: "password123", role: role_admin)
      expect(user2).not_to be_valid
      expect(user2.errors[:cpf]).to be_present
    end

    it "valida formato de e-mail quando informado" do
      user = User.new(nome: "Teste", cpf: "99988877766", email: "email_invalido", password: "password123", role: role_admin)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "permite e-mail em branco" do
      user = User.new(nome: "Teste", cpf: "99988877766", email: "", password: "password123", role: role_admin)
      expect(user).to be_valid
    end

    it "valida tamanho mínimo de senha" do
      user = User.new(nome: "Teste", cpf: "99988877766", password: "123", role: role_admin)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe "normalizações (Rails normalizes)" do
    it "sanitiza CPF, telefone, email e nome automaticamente" do
      user = User.create!(
        nome: "   Lucas da Silva   ",
        cpf: "123.456.789-01",
        email: "  LUCAS@Teste.COM  ",
        telefone: "(11) 98888-7777",
        password: "password123",
        role: role_tecnico
      )

      expect(user.nome).to eq("Lucas da Silva")
      expect(user.cpf).to eq("12345678901")
      expect(user.email).to eq("lucas@teste.com")
      expect(user.telefone).to eq("11988887777")
    end

    it "permite consulta find_by com valor não normalizado via normalizes" do
      User.create!(
        nome: "Ana",
        cpf: "55566677788",
        email: "ana@teste.com",
        password: "password123",
        role: role_admin
      )

      encontrado = User.find_by(email: "  ANA@TESTE.COM  ")
      expect(encontrado).to be_present
      expect(encontrado.cpf).to eq("55566677788")
    end
  end

  describe "métodos de perfil e scopes" do
    let!(:tecnico) do
      User.create!(nome: "Técnico Silva", cpf: "44455566677", password: "password123", role: role_tecnico)
    end
    let!(:admin) do
      User.create!(nome: "Admin Santos", cpf: "88899900011", password: "password123", role: role_admin)
    end

    it "identifica corretamente o papel do usuário" do
      expect(tecnico.tecnico?).to be true
      expect(tecnico.admin?).to be false
      expect(admin.admin?).to be true
      expect(admin.tecnico?).to be false
    end

    it "filtra usuários pelos scopes correspondentes" do
      expect(User.tecnicos).to include(tecnico)
      expect(User.tecnicos).not_to include(admin)
      expect(User.administradores).to include(admin)
    end
  end
end
