# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Andares API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/andares" do
    get "Lista andares" do
      tags "Andares"
      description "Retorna a lista de andares cadastrados."
      operationId "getAndares"
      produces "application/json"

      response "200", "Lista retornada com sucesso" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              descricao: { type: :string, example: "Exemplo descricao" }
            }
          }
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end

    post "Cadastra um novo andar" do
      tags "Andares"
      operationId "createAndar"
      consumes "application/json"
      produces "application/json"

      parameter name: :andar_params, in: :body, schema: {
        type: :object,
        properties: {
          andar: {
            type: :object,
            properties: {
              descricao: { type: :string, example: "Exemplo descricao" }
            },
            required: %w[descricao]
          }
        },
        required: %w[andar]
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

  path "/api/v1/andares/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único de Andar", example: 1

    get "Visualiza detalhes de andar" do
      tags "Andares"
      operationId "getAndar"
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

    patch "Atualiza andar" do
      tags "Andares"
      operationId "updateAndar"
      consumes "application/json"
      produces "application/json"

      parameter name: :andar_update, in: :body, schema: {
        type: :object,
        properties: {
          andar: {
            type: :object,
            properties: {
              descricao: { type: :string, example: "Exemplo descricao" }
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

    delete "Remove andar" do
      tags "Andares"
      operationId "deleteAndar"
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
