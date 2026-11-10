# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Status API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/status" do
    get "Lista status disponíveis para ordens de serviço" do
      tags "Status"
      description "Retorna a listagem de status cadastrados (ex: Aberta, Em Andamento, Aguardando Peça, Finalizada)."
      operationId "getStatusList"
      produces "application/json"

      response "200", "Lista de status retornada" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              nome: { type: :string, example: "Aberta" }
            }
          }
        run_test!
      end
    end

    post "Cadastra um novo status" do
      tags "Status"
      operationId "createStatus"
      consumes "application/json"
      produces "application/json"

      parameter name: :status_params, in: :body, schema: {
        type: :object,
        properties: {
          status: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Aguardando Aprovação de Orçamento" }
            },
            required: %w[nome]
          }
        },
        required: %w[status]
      }

      response "201", "Status criado com sucesso" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/status/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único do Status", example: 1

    get "Visualiza detalhes de um status" do
      tags "Status"
      operationId "getStatus"
      produces "application/json"

      response "200", "Status encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza o nome de um status" do
      tags "Status"
      operationId "updateStatus"
      consumes "application/json"
      produces "application/json"

      parameter name: :status_update, in: :body, schema: {
        type: :object,
        properties: {
          status: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Em Andamento (Técnico em Deslocamento)" }
            }
          }
        }
      }

      response "200", "Status atualizado" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove um status" do
      tags "Status"
      operationId "deleteStatus"
      produces "application/json"

      response "204", "Status removido" do
        run_test!
      end
    end
  end
end
