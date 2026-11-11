# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Materiais API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/materiais" do
    get "Lista catálogo de materiais" do
      tags "Materiais"
      description "Retorna a lista de materiais cadastrados no catálogo com seus valores de referência."
      operationId "getMateriais"
      produces "application/json"

      response "200", "Catálogo de materiais retornado" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              nome: { type: :string, example: "Gás refrigerante R410A" },
              descricao: { type: :string, nullable: true, example: "Carga de fluido refrigerante R410A para sistemas split e inverter." },
              valor_referencia: { type: :string, nullable: true, example: "140.0" }
            }
          }
        run_test!
      end

      response "401", "Não autorizado" do
        schema type: :object
        run_test!
      end
    end

    post "Cadastra um novo material" do
      tags "Materiais"
      description "Adiciona um novo material ao catálogo (Administrador e Secretaria)."
      operationId "createMaterial"
      consumes "application/json"
      produces "application/json"

      parameter name: :material_params, in: :body, schema: {
        type: :object,
        properties: {
          material: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Tubulação de cobre 1/4 pol." },
              descricao: { type: :string, nullable: true, example: "Metro de tubo de cobre flexível para linha frigorígena." },
              valor_referencia: { type: :number, format: :decimal, nullable: true, example: 45.0 }
            },
            required: %w[nome]
          }
        },
        required: %w[material]
      }

      response "201", "Material cadastrado com sucesso" do
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

  path "/api/v1/materiais/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único do Material", example: 1

    get "Visualiza detalhes de um material" do
      tags "Materiais"
      operationId "getMaterial"
      produces "application/json"

      response "200", "Material encontrado" do
        schema type: :object
        run_test!
      end

      response "401", "Não autorizado" do
        schema type: :object
        run_test!
      end

      response "404", "Material não encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza dados de um material" do
      tags "Materiais"
      operationId "updateMaterial"
      consumes "application/json"
      produces "application/json"

      parameter name: :material_update, in: :body, schema: {
        type: :object,
        properties: {
          material: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Tubulação de cobre 3/8 pol." },
              descricao: { type: :string, nullable: true, example: "Metro de tubo de cobre flexível reforçado." },
              valor_referencia: { type: :number, format: :decimal, nullable: true, example: 58.0 }
            }
          }
        }
      }

      response "200", "Material atualizado" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Material não encontrado" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove um material do catálogo" do
      tags "Materiais"
      operationId "deleteMaterial"
      produces "application/json"

      response "204", "Material removido" do
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Material não encontrado" do
        schema type: :object
        run_test!
      end
    end
  end
end
