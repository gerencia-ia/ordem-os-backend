# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Autenticação API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/login" do
    post "Realiza autenticação do usuário" do
      tags "Autenticação"
      description "Autentica um usuário via CPF e senha. Retorna um Bearer token de sessão que deve ser usado nas demais rotas protegidas."
      operationId "login"
      consumes "application/json"
      produces "application/json"
      security [] # Endpoint público

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          cpf: {
            type: :string,
            description: "CPF cadastrado (aceita com ou sem pontuação)",
            example: "11111111111"
          },
          password: {
            type: :string,
            description: "Senha do usuário",
            example: "123456"
          }
        },
        required: %w[cpf password]
      }

      response "200", "Autenticado com sucesso" do
        schema type: :object,
          properties: {
            token: { type: :string, example: "a1b2c3d4e5f6g7h8i9j0" },
            user: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                nome: { type: :string, example: "Sophia Marlene" },
                email: { type: :string, example: "sophia@example.com" },
                cpf: { type: :string, example: "11111111111" },
                telefone: { type: :string, example: "73993564830" },
                role_id: { type: :integer, example: 1 },
                role: {
                  type: :object,
                  properties: {
                    id: { type: :integer, example: 1 },
                    nome: { type: :string, example: "Secretaria" }
                  }
                }
              }
            }
          }

        let(:credentials) { { cpf: "11111111111", password: "password123" } }
        run_test!
      end

      response "401", "CPF ou senha inválidos" do
        schema type: :object,
          properties: {
            error: { type: :string, example: "CPF ou senha inválidos" }
          }

        let(:credentials) { { cpf: "00000000000", password: "wrong" } }
        run_test!
      end

      response "429", "Muitas tentativas de login (Rate limit)" do
        schema type: :object,
          properties: {
            error: { type: :string, example: "Muitas tentativas de login. Tente novamente mais tarde." }
          }
      end
    end
  end

  path "/api/v1/logout" do
    delete "Encerra a sessão ativa (Logout)" do
      tags "Autenticação"
      description "Invalida imediatamente o token da sessão ativa no banco de dados."
      operationId "logout"
      produces "application/json"
      security [ { bearer_auth: [] } ]

      response "204", "Logout realizado com sucesso" do
        let(:Authorization) { "Bearer token_exemplo" }
        run_test!
      end

      response "401", "Não autorizado ou token ausente/inválido" do
        schema type: :object,
          properties: {
            error: { type: :string, example: "Não autorizado" }
          }
      end
    end
  end
end
