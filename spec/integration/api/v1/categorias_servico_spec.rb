# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Categorias de Serviço API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/categorias_servico" do
    get "Lista categorias de serviço" do
      tags "Categorias de Serviço"
      description "Retorna as categorias que agrupam os serviços prestados (ex: Higienização, Instalação, Reparo Elétrico)."
      operationId "getCategoriasServico"
      produces "application/json"

      response "200", "Lista de categorias retornada" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              descricao: { type: :string, example: "Manutenção Preventiva" }
            }
          }
        run_test!
      end
    end

    post "Cadastra uma nova categoria" do
      tags "Categorias de Serviço"
      operationId "createCategoriaServico"
      consumes "application/json"
      produces "application/json"

      parameter name: :categoria_params, in: :body, schema: {
        type: :object,
        properties: {
          categorias_servico: {
            type: :object,
            properties: {
              descricao: { type: :string, example: "Instalação e Infraestrutura" }
            },
            required: %w[descricao]
          }
        },
        required: %w[categorias_servico]
      }

      response "201", "Categoria criada com sucesso" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/categorias_servico/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único da Categoria", example: 1

    get "Visualiza detalhes de uma categoria" do
      tags "Categorias de Serviço"
      operationId "getCategoriaServico"
      produces "application/json"

      response "200", "Categoria localizada" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza a descrição de uma categoria" do
      tags "Categorias de Serviço"
      operationId "updateCategoriaServico"
      consumes "application/json"
      produces "application/json"

      parameter name: :categoria_update, in: :body, schema: {
        type: :object,
        properties: {
          categorias_servico: {
            type: :object,
            properties: {
              descricao: { type: :string, example: "Instalação, Tubulação e Infraestrutura" }
            }
          }
        }
      }

      response "200", "Categoria atualizada" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove uma categoria de serviço" do
      tags "Categorias de Serviço"
      operationId "deleteCategoriaServico"
      produces "application/json"

      response "204", "Categoria removida" do
        run_test!
      end
    end
  end
end
