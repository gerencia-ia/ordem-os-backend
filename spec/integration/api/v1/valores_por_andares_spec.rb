# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Valores Por Andares API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/valores_por_andares" do
    get "Lista valores por andares" do
      tags "Valores Por Andares"
      description "Retorna a lista de valores por andares cadastrados."
      operationId "getValoresPorAndares"
      produces "application/json"

      response "200", "Lista retornada com sucesso" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              servico_id: { type: :integer, example: 1 },
              andar_id: { type: :integer, example: 1 },
              valor: { type: :string, example: "10.50" }
            }
          }
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end

    post "Cadastra um novo valor por andar" do
      tags "Valores Por Andares"
      operationId "createValorPorAndar"
      consumes "application/json"
      produces "application/json"

      parameter name: :valor_por_andar_params, in: :body, schema: {
        type: :object,
        properties: {
          valor_por_andar: {
            type: :object,
            properties: {
              servico_id: { type: :integer, example: 1 },
              andar_id: { type: :integer, example: 1 },
              valor: { type: :string, example: "10.50" }
            },
            required: %w[servico_id andar_id valor]
          }
        },
        required: %w[valor_por_andar]
      }

      response "201", "Registro cadastrado com sucesso" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/valores_por_andares/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único de ValorPorAndar", example: 1

    get "Visualiza detalhes de valor por andar" do
      tags "Valores Por Andares"
      operationId "getValorPorAndar"
      produces "application/json"

      response "200", "Registro encontrado" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Registro não encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza valor por andar" do
      tags "Valores Por Andares"
      operationId "updateValorPorAndar"
      consumes "application/json"
      produces "application/json"

      parameter name: :valor_por_andar_update, in: :body, schema: {
        type: :object,
        properties: {
          valor_por_andar: {
            type: :object,
            properties: {
              servico_id: { type: :integer, example: 1 },
              andar_id: { type: :integer, example: 1 },
              valor: { type: :string, example: "10.50" }
            }
          }
        }
      }

      response "200", "Registro atualizado" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove valor por andar" do
      tags "Valores Por Andares"
      operationId "deleteValorPorAndar"
      produces "application/json"

      response "204", "Registro removido" do
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end
  end
end
