# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Authentication", type: :request do
  let!(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let!(:user) do
    User.create!(
      nome: "Admin Teste",
      cpf: "99988877766",
      email: "adm@teste.com",
      password: "password123",
      role: role_admin
    )
  end
  let!(:session) { user.sessions.create! }

  describe "Controle de autenticação em endpoints protegidos" do
    it "retorna 401 Unauthorized quando não é enviado o cabeçalho Authorization" do
      get "/api/v1/users"

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Não autorizado")
    end

    it "retorna 401 Unauthorized quando o token fornecido é inválido" do
      get "/api/v1/users", headers: { "Authorization" => "Bearer token_falso_123" }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Não autorizado")
    end

    it "permite o acesso com header 'Authorization: Bearer <token>'" do
      get "/api/v1/users", headers: { "Authorization" => "Bearer #{session.token}" }

      expect(response).to have_http_status(:ok)
    end

    it "permite o acesso com header 'Authorization: <token>' sem prefixo" do
      get "/api/v1/users", headers: { "Authorization" => session.token }

      expect(response).to have_http_status(:ok)
    end
  end
end
