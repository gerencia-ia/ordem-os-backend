# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Papéis (Roles) API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/roles" do
    get "Lista papéis de usuário" do
      tags "Papéis"
      description "Retorna a lista de papéis disponíveis no sistema (ex: Administrador, Secretaria, Técnico)."
      operationId "getRoles"
      produces "application/json"

      response "200", "Lista de papéis retornada" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              nome: { type: :string, example: "Administrador" }
            }
          }
        run_test!
      end
    end

    post "Cadastra um novo papel" do
      tags "Papéis"
      description "Cria um novo papel de acesso (restrito a Administradores)."
      operationId "createRole"
      consumes "application/json"
      produces "application/json"

      parameter name: :role_params, in: :body, schema: {
        type: :object,
        properties: {
          role: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Supervisor" }
            },
            required: %w[nome]
          }
        },
        required: %w[role]
      }

      response "201", "Papel cadastrado com sucesso" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado (apenas Administradores podem gerenciar papéis)" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/roles/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único do Papel", example: 1

    get "Visualiza detalhes de um papel" do
      tags "Papéis"
      operationId "getRole"
      produces "application/json"

      response "200", "Papel encontrado" do
        schema type: :object
        run_test!
      end

      response "404", "Papel não encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza o nome de um papel" do
      tags "Papéis"
      operationId "updateRole"
      consumes "application/json"
      produces "application/json"

      parameter name: :role_update, in: :body, schema: {
        type: :object,
        properties: {
          role: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Coordenador Técnico" }
            }
          }
        }
      }

      response "200", "Papel atualizado" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove um papel" do
      tags "Papéis"
      operationId "deleteRole"
      produces "application/json"

      response "204", "Papel excluído" do
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end
  end
end
