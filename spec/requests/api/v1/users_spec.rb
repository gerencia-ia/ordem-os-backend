# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let!(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let!(:role_tecnico) { Role.find_or_create_by!(nome: "Técnico") }

  let!(:admin) do
    User.create!(
      nome: "Admin Teste",
      cpf: "11111111111",
      email: "admin@teste.com",
      telefone: "11999999999",
      password: "password123",
      role: role_admin
    )
  end

  def auth_header(user)
    session = user.sessions.create!
    { "Authorization" => "Bearer #{session.token}" }
  end

  describe "POST /api/v1/users" do
    it "cadastra usuário recebendo payload JSON plano com password" do
      post "/api/v1/users",
           params: {
             nome: "Carlos Silva",
             cpf: "55566677788",
             email: "carlos@teste.com",
             telefone: "11987654321",
             password: "senhaSegura123",
             role_id: role_tecnico.id
           },
           headers: auth_header(admin),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["nome"]).to eq("Carlos Silva")
      expect(body["role_id"]).to eq(role_tecnico.id)

      created_user = User.find(body["id"])
      expect(created_user.authenticate("senhaSegura123")).to eq(created_user)
    end

    it "cadastra usuário recebendo payload JSON encapsulado sob a chave user" do
      post "/api/v1/users",
           params: {
             user: {
               nome: "Maria Souza",
               cpf: "66677788899",
               email: "maria@teste.com",
               telefone: "11912345678",
               password: "outraSenha123",
               role_id: role_tecnico.id
             }
           },
           headers: auth_header(admin),
           as: :json

      expect(response).to have_http_status(:created)
      created_user = User.find(JSON.parse(response.body)["id"])
      expect(created_user.authenticate("outraSenha123")).to eq(created_user)
    end

    it "retorna 422 quando password está em branco no cadastro" do
      post "/api/v1/users",
           params: {
             nome: "Sem Senha",
             cpf: "77788899900",
             email: "semsenha@teste.com",
             telefone: "11911112222",
             password: "",
             role_id: role_tecnico.id
           },
           headers: auth_header(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/users/:id" do
    let!(:tecnico) do
      User.create!(
        nome: "Técnico Original",
        cpf: "22233344455",
        email: "tecnico@teste.com",
        telefone: "11900001111",
        password: "senhaAntiga123",
        role: role_tecnico
      )
    end

    it "atualiza a senha recebendo payload JSON plano" do
      patch "/api/v1/users/#{tecnico.id}",
            params: {
              nome: "Técnico Atualizado",
              password: "novaSenha123"
            },
            headers: auth_header(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      tecnico.reload
      expect(tecnico.nome).to eq("Técnico Atualizado")
      expect(tecnico.authenticate("novaSenha123")).to eq(tecnico)
    end

    it "mantém a senha atual quando password vem em branco na atualização" do
      patch "/api/v1/users/#{tecnico.id}",
            params: {
              nome: "Técnico Sem Trocar Senha",
              password: ""
            },
            headers: auth_header(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      tecnico.reload
      expect(tecnico.nome).to eq("Técnico Sem Trocar Senha")
      expect(tecnico.authenticate("senhaAntiga123")).to eq(tecnico)
    end
  end
end
