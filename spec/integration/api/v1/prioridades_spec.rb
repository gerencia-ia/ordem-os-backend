# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Prioridades API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/prioridades" do
    get "Lista prioridades de atendimento" do
      tags "Prioridades"
      description "Retorna as prioridades configuradas para as ordens de serviço (ex: Baixa, Normal, Alta, Urgente)."
      operationId "getPrioridades"
      produces "application/json"

      response "200", "Lista de prioridades retornada" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              descricao: { type: :string, example: "Alta" }
            }
          }
        run_test!
      end
    end

    post "Cadastra uma nova prioridade" do
      tags "Prioridades"
      operationId "createPrioridade"
      consumes "application/json"
      produces "application/json"

      parameter name: :prioridade_params, in: :body, schema: {
        type: :object,
        properties: {
          prioridade: {
            type: :object,
            properties: {
              descricao: { type: :string, example: "Emergencial" }
            },
            required: %w[descricao]
          }
        },
        required: %w[prioridade]
      }

      response "201", "Prioridade cadastrada" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/prioridades/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único da Prioridade", example: 1

    get "Visualiza detalhes de uma prioridade" do
      tags "Prioridades"
      operationId "getPrioridade"
      produces "application/json"

      response "200", "Prioridade encontrada" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza uma prioridade" do
      tags "Prioridades"
      operationId "updatePrioridade"
      consumes "application/json"
      produces "application/json"

      parameter name: :prioridade_update, in: :body, schema: {
        type: :object,
        properties: {
          prioridade: {
            type: :object,
            properties: {
              descricao: { type: :string, example: "Crítica" }
            }
          }
        }
      }

      response "200", "Prioridade atualizada" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove uma prioridade" do
      tags "Prioridades"
      operationId "deletePrioridade"
      produces "application/json"

      response "204", "Prioridade removida" do
        run_test!
      end
    end
  end
end
