# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Andares", type: :request do
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

  let!(:tecnico) do
    User.create!(
      nome: "Tecnico Teste",
      cpf: "22222222222",
      email: "tecnico@teste.com",
      telefone: "11988888888",
      password: "password123",
      role: role_tecnico
    )
  end

  let(:valid_attributes) do
    {
      descricao: "Exemplo descricao"
    }
  end

  let(:update_attributes) do
    {
      descricao: "Exemplo descricao atualizado"
    }
  end

  let(:invalid_attributes) do
    {
      descricao: nil
    }
  end

  def auth_header(user)
    session = user.sessions.create!
    { "Authorization" => "Bearer #{session.token}" }
  end

  describe "autenticação e autorização" do
    it "retorna 401 quando enviado sem token" do
      get "/api/v1/andares"
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 403 quando usuário não administrador acessa o recurso" do
      get "/api/v1/andares", headers: auth_header(tecnico)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/andares" do
    let!(:record) { Andar.create!(valid_attributes) }

    it "lista os registros para administrador" do
      get "/api/v1/andares", headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |item| item["id"] }).to include(record.id)
    end
  end

  describe "GET /api/v1/andares/:id" do
    let!(:record) { Andar.create!(valid_attributes) }

    it "retorna o registro solicitado" do
      get "/api/v1/andares/#{record.id}", headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(record.id)
    end

    it "retorna 404 quando não encontrado" do
      get "/api/v1/andares/0", headers: auth_header(admin)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/andares" do
    it "cria um novo registro com parâmetros válidos" do
      expect do
        post "/api/v1/andares",
             params: { andar: valid_attributes },
             headers: auth_header(admin),
             as: :json
      end.to change(Andar, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "retorna 422 com parâmetros inválidos" do
      post "/api/v1/andares",
           params: { andar: invalid_attributes },
           headers: auth_header(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body).to have_key("errors")
    end
  end

  describe "PATCH /api/v1/andares/:id" do
    let!(:record) { Andar.create!(valid_attributes) }

    it "atualiza o registro com sucesso" do
      patch "/api/v1/andares/#{record.id}",
            params: { andar: update_attributes },
            headers: auth_header(admin),
            as: :json

      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/v1/andares/:id" do
    let!(:record) { Andar.create!(valid_attributes) }

    it "remove o registro com sucesso" do
      expect do
        delete "/api/v1/andares/#{record.id}", headers: auth_header(admin)
      end.to change(Andar, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
