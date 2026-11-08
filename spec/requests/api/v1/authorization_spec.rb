# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Authorization", type: :request do
  let!(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let!(:role_secretaria) { Role.find_or_create_by!(nome: "Secretaria") }
  let!(:role_tecnico) { Role.find_or_create_by!(nome: "Técnico") }

  let!(:admin) do
    User.create!(
      nome: "Admin",
      cpf: "11111111111",
      email: "admin@test.com",
      password: "password123",
      role: role_admin
    )
  end

  let!(:secretaria) do
    User.create!(
      nome: "Secretaria",
      cpf: "22222222222",
      email: "secretaria@test.com",
      password: "password123",
      role: role_secretaria
    )
  end

  let!(:tecnico1) do
    User.create!(
      nome: "Tecnico 1",
      cpf: "33333333333",
      email: "tecnico1@test.com",
      password: "password123",
      role: role_tecnico
    )
  end

  let!(:tecnico2) do
    User.create!(
      nome: "Tecnico 2",
      cpf: "44444444444",
      email: "tecnico2@test.com",
      password: "password123",
      role: role_tecnico
    )
  end

  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Teste",
      email: "cliente@teste.com",
      enderecos_attributes: [
        { rua: "Rua 1", numero: "100", bairro: "Centro", cidade: "Cidade", cep: "12345000" }
      ],
      telefones_attributes: [
        { numero: "11999999999" }
      ]
    )
  end
  let!(:prioridade) { Prioridade.create!(descricao: "Alta") }
  let!(:status_aberta) { Status.create!(nome: "Aberta") }

  let!(:os_tecnico1) do
    os = OrdemServico.create!(
      numero_ordem: "OS-001",
      descricao: "Manutenção 1",
      cliente: cliente,
      endereco: cliente.enderecos.first,
      prioridade: prioridade,
      status: status_aberta
    )
    os.os_tecnicos.create!(user: tecnico1)
    os
  end

  let!(:os_tecnico2) do
    os = OrdemServico.create!(
      numero_ordem: "OS-002",
      descricao: "Manutenção 2",
      cliente: cliente,
      endereco: cliente.enderecos.first,
      prioridade: prioridade,
      status: status_aberta
    )
    os.os_tecnicos.create!(user: tecnico2)
    os
  end

  def auth_header(user)
    session = user.sessions.create!
    { "Authorization" => "Bearer #{session.token}" }
  end

  describe "Controle de Acesso em Ordens de Serviço" do
    context "como Técnico" do
      it "retorna apenas as ordens de serviço atribuídas ao técnico logado (Policy Scope)" do
        get "/api/v1/ordem_servicos", headers: auth_header(tecnico1)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        ids = body.map { |os| os["id"] }

        expect(ids).to include(os_tecnico1.id)
        expect(ids).not_to include(os_tecnico2.id)
      end

      it "retorna 403 Forbidden ao tentar visualizar uma OS não atribuída a ele" do
        get "/api/v1/ordem_servicos/#{os_tecnico2.id}", headers: auth_header(tecnico1)

        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Acesso negado")
      end

      it "permite visualizar sua própria OS atribuída" do
        get "/api/v1/ordem_servicos/#{os_tecnico1.id}", headers: auth_header(tecnico1)

        expect(response).to have_http_status(:ok)
      end

      it "retorna 403 Forbidden ao tentar excluir uma OS" do
        delete "/api/v1/ordem_servicos/#{os_tecnico1.id}", headers: auth_header(tecnico1)

        expect(response).to have_http_status(:forbidden)
      end

      it "retorna 403 Forbidden ao tentar criar uma nova OS" do
        post "/api/v1/ordem_servicos",
             params: { ordem_servico: { numero_ordem: "OS-999", cliente_id: cliente.id } },
             headers: auth_header(tecnico1)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "como Secretaria" do
      it "visualiza todas as ordens de serviço no index" do
        get "/api/v1/ordem_servicos", headers: auth_header(secretaria)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        ids = body.map { |os| os["id"] }

        expect(ids).to include(os_tecnico1.id, os_tecnico2.id)
      end

      it "pode criar ordens de serviço" do
        post "/api/v1/ordem_servicos",
             params: {
               ordem_servico: {
                 numero_ordem: "OS-NEW",
                 cliente_id: cliente.id,
                 endereco_id: cliente.enderecos.first.id,
                 prioridade_id: prioridade.id,
                 status_id: status_aberta.id
               }
             },
             headers: auth_header(secretaria)

        expect(response).to have_http_status(:created)
      end

      it "não pode criar ou deletar papéis (Roles)" do
        post "/api/v1/roles",
             params: { role: { nome: "SuperUser" } },
             headers: auth_header(secretaria)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "como Administrador" do
      it "pode gerenciar papéis e qualquer recurso" do
        post "/api/v1/roles",
             params: { role: { nome: "Gerente" } },
             headers: auth_header(admin)

        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "Proteção contra Escalonamento de Privilégios (Users)" do
    it "impede que um técnico altere seu próprio papel para Administrador" do
      patch "/api/v1/users/#{tecnico1.id}",
            params: { user: { role_id: role_admin.id, nome: "Tecnico Tentando Virar Admin" } },
            headers: auth_header(tecnico1)

      expect(response).to have_http_status(:ok)
      tecnico1.reload
      expect(tecnico1.role_id).to eq(role_tecnico.id) # Não foi alterado para admin!
      expect(tecnico1.nome).to eq("Tecnico Tentando Virar Admin")
    end

    it "retorna 403 se um técnico tentar excluir outro usuário" do
      delete "/api/v1/users/#{tecnico2.id}", headers: auth_header(tecnico1)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
