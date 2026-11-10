# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Serviços API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/servicos" do
    get "Lista catálogo de serviços" do
      tags "Serviços"
      description "Retorna a lista de serviços cadastrados com seus valores, tempos médios de execução e categorias."
      operationId "getServicos"
      produces "application/json"

      response "200", "Catálogo de serviços retornado" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              nome: { type: :string, example: "Higienização Química de Split até 18.000 BTUs" },
              valor: { type: :string, example: "220.00" },
              tempo_servico: { type: :integer, example: 90, description: "Tempo estimado em minutos" },
              categorias_servico_id: { type: :integer, example: 1 },
              categorias_servico: {
                type: :object,
                properties: {
                  id: { type: :integer, example: 1 },
                  descricao: { type: :string, example: "Manutenção Preventiva" }
                }
              }
            }
          }
        run_test!
      end
    end

    post "Cadastra um novo serviço" do
      tags "Serviços"
      description "Adiciona um novo serviço com preço e categoria ao catálogo (Administrador e Secretaria)."
      operationId "createServico"
      consumes "application/json"
      produces "application/json"

      parameter name: :servico_params, in: :body, schema: {
        type: :object,
        properties: {
          servico: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Carga de Gás Refrigerante R410A" },
              valor: { type: :string, example: "350.00" },
              tempo_servico: { type: :integer, example: 60, description: "Tempo estimado em minutos" },
              categorias_servico_id: { type: :integer, example: 2 }
            },
            required: %w[nome valor categorias_servico_id]
          }
        },
        required: %w[servico]
      }

      response "201", "Serviço cadastrado com sucesso" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/servicos/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único do Serviço", example: 1

    get "Visualiza detalhes de um serviço" do
      tags "Serviços"
      operationId "getServico"
      produces "application/json"

      response "200", "Serviço encontrado" do
        schema type: :object
        run_test!
      end

      response "404", "Serviço não encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza dados de um serviço" do
      tags "Serviços"
      operationId "updateServico"
      consumes "application/json"
      produces "application/json"

      parameter name: :servico_update, in: :body, schema: {
        type: :object,
        properties: {
          servico: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Carga de Gás R410A (até 30.000 BTUs)" },
              valor: { type: :string, example: "380.00" },
              tempo_servico: { type: :integer, example: 75, description: "Tempo estimado em minutos" }
            }
          }
        }
      }

      response "200", "Serviço atualizado" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove um serviço do catálogo" do
      tags "Serviços"
      operationId "deleteServico"
      produces "application/json"

      response "204", "Serviço removido" do
        run_test!
      end
    end
  end
end
