# frozen_string_literal: true

require "rails_helper"

RSpec.describe Role, type: :model do
  describe "validações" do
    it "é válido com nome preenchido" do
      role = Role.new(nome: "Gerente")
      expect(role).to be_valid
    end

    it "exige a presença de nome" do
      role = Role.new(nome: nil)
      expect(role).not_to be_valid
      expect(role.errors[:nome]).to be_present
    end

    it "exige unicidade do nome (case insensitive)" do
      Role.create!(nome: "Supervisor")
      duplicado = Role.new(nome: "supervisor")
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:nome]).to be_present
    end
  end

  describe "normalização" do
    it "remove espaços em branco nas extremidades do nome" do
      role = Role.create!(nome: "   Operador   ")
      expect(role.nome).to eq("Operador")
    end
  end

  describe "associações e integridade" do
    let!(:role) { Role.create!(nome: "Especialista") }
    let!(:user) do
      User.create!(
        nome: "Carlos",
        cpf: "12345678901",
        email: "carlos@teste.com",
        password: "password123",
        role: role
      )
    end

    it "impede a exclusão da role se houver usuários vinculados" do
      expect { role.destroy }.not_to change(Role, :count)
      expect(role.errors[:base]).to be_present
    end
  end

  describe "scopes" do
    let!(:admin_role) { Role.find_or_create_by!(nome: "Administrador") }
    let!(:tecnico_role) { Role.find_or_create_by!(nome: "Tecnico") }
    let!(:secretaria_role) { Role.find_or_create_by!(nome: "Secretaria") }

    it "retorna as roles pelos scopes correspondentes" do
      expect(Role.administradores).to include(admin_role)
      expect(Role.tecnicos).to include(tecnico_role)
      expect(Role.secretarias).to include(secretaria_role)
    end
  end
end
