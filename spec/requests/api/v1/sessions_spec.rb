# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  let!(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let!(:user) do
    User.create!(
      nome: "Admin Teste",
      cpf: "12345678901",
      email: "admin@teste.com",
      telefone: "11999999999",
      password: "password123",
      role: role_admin
    )
  end

  describe "POST /api/v1/login" do
    it "realiza login com sucesso e retorna token da sessão" do
      post "/api/v1/login", params: { cpf: "12345678901", password: "password123" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body).to have_key("token")
      expect(body["token"]).to be_present
      expect(body["user"]["id"]).to eq(user.id)
      expect(body["user"]["cpf"]).to eq("12345678901")

      session = Session.find_by(token: body["token"])
      expect(session).to be_present
      expect(session.user_id).to eq(user.id)
    end

    it "aceita CPF formatado com pontos e traço" do
      post "/api/v1/login", params: { cpf: "123.456.789-01", password: "password123" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["token"]).to be_present
    end

    it "retorna 401 com senha incorreta" do
      post "/api/v1/login", params: { cpf: "12345678901", password: "senha_errada" }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("CPF ou senha inválidos")
    end

    it "retorna 401 com CPF inexistente" do
      post "/api/v1/login", params: { cpf: "00000000000", password: "password123" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/logout" do
    let!(:session) { user.sessions.create! }

    it "destrói a sessão e invalida o token para requisições subsequentes" do
      delete "/api/v1/logout", headers: { "Authorization" => "Bearer #{session.token}" }

      expect(response).to have_http_status(:no_content)
      expect(Session.find_by(id: session.id)).to be_nil

      # Tentativa subsequente de acessar rota protegida com o mesmo token deve retornar 401
      get "/api/v1/users", headers: { "Authorization" => "Bearer #{session.token}" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 401 quando chamado sem autenticação" do
      delete "/api/v1/logout"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
