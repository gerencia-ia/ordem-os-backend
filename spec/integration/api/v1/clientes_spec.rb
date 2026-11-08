# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Clientes API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/clientes" do
    get "Lista todos os clientes" do
      tags "Clientes"
      description "Retorna a lista completa de clientes cadastrados, incluindo seus respectivos endereços e telefones."
      operationId "getClientes"
      produces "application/json"

      response "200", "Lista de clientes retornada com sucesso" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              nome: { type: :string, example: "João da Silva" },
              email: { type: :string, example: "joao.silva@email.com" },
              data_registro: { type: :string, format: :date, example: "2026-01-10" },
              data_ultima_visita: { type: :string, format: :date, example: "2026-03-15" },
              enderecos: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer, example: 1 },
                    rua: { type: :string, example: "Av. Paulista" },
                    numero: { type: :string, example: "1000" },
                    bairro: { type: :string, example: "Bela Vista" },
                    complemento: { type: :string, example: "Apto 42" },
                    cep: { type: :string, example: "01310100" },
                    cidade: { type: :string, example: "São Paulo" }
                  }
                }
              },
              telefones: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer, example: 1 },
                    numero: { type: :string, example: "11988887777" }
                  }
                }
              }
            }
          }
        run_test!
      end

      response "401", "Não autorizado" do
        schema type: :object, properties: { error: { type: :string, example: "Não autorizado" } }
        run_test!
      end
    end

    post "Cadastra um novo cliente" do
      tags "Clientes"
      description "Cria um novo cliente com suporte a cadastro aninhado de endereços, telefones e equipamentos em uma única requisição."
      operationId "createCliente"
      consumes "application/json"
      produces "application/json"

      parameter name: :cliente_params, in: :body, schema: {
        type: :object,
        properties: {
          cliente: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Supermercado Progresso Ltda" },
              email: { type: :string, example: "contato@superprogresso.com.br" },
              data_registro: { type: :string, format: :date, example: "2026-11-08" },
              data_ultima_visita: { type: :string, format: :date, example: "2026-11-08" },
              enderecos_attributes: {
                type: :array,
                description: "Lista de endereços (obrigatório ao menos 1)",
                items: {
                  type: :object,
                  properties: {
                    rua: { type: :string, example: "Rua do Comércio" },
                    numero: { type: :string, example: "500" },
                    bairro: { type: :string, example: "Centro Comercial" },
                    complemento: { type: :string, example: "Galpão 2" },
                    cep: { type: :string, example: "45600000" },
                    cidade: { type: :string, example: "Itabuna" }
                  },
                  required: %w[rua numero bairro cidade]
                }
              },
              telefones_attributes: {
                type: :array,
                description: "Lista de telefones (obrigatório ao menos 1)",
                items: {
                  type: :object,
                  properties: {
                    numero: { type: :string, example: "73988889999" }
                  },
                  required: %w[numero]
                }
              },
              equipamentos_attributes: {
                type: :array,
                description: "Equipamentos do cliente cadastrados previamente",
                items: {
                  type: :object,
                  properties: {
                    marca: { type: :string, example: "Carrier" },
                    btus: { type: :integer, example: 36000 },
                    local_instalacao: { type: :string, example: "Área de Vendas - Caixa 1" },
                    observacao: { type: :string, example: "Revisão preventiva semestral" }
                  }
                }
              }
            },
            required: %w[nome enderecos_attributes telefones_attributes]
          }
        },
        required: %w[cliente]
      }

      response "201", "Cliente cadastrado com sucesso" do
        schema type: :object,
          properties: {
            id: { type: :integer, example: 10 },
            nome: { type: :string, example: "Supermercado Progresso Ltda" },
            email: { type: :string, example: "contato@superprogresso.com.br" },
            enderecos: { type: :array, items: { type: :object } },
            telefones: { type: :array, items: { type: :object } }
          }
        run_test!
      end

      response "422", "Erro de validação cadastral" do
        schema type: :object,
          properties: {
            errors: {
              type: :object,
              example: {
                enderecos: ["deve conter ao menos um endereço"],
                telefones: ["deve conter ao menos um telefone"]
              }
            }
          }
        run_test!
      end

      response "403", "Acesso negado (permissão insuficiente)" do
        schema type: :object, properties: { error: { type: :string, example: "Acesso negado" } }
        run_test!
      end
    end
  end

  path "/api/v1/clientes/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único do cliente", example: 1

    get "Visualiza detalhes de um cliente" do
      tags "Clientes"
      description "Retorna as informações completas de um cliente específico com seus endereços e telefones."
      operationId "getCliente"
      produces "application/json"

      response "200", "Cliente localizado" do
        schema type: :object,
          properties: {
            id: { type: :integer, example: 1 },
            nome: { type: :string, example: "João da Silva" },
            email: { type: :string, example: "joao.silva@email.com" },
            enderecos: { type: :array, items: { type: :object } },
            telefones: { type: :array, items: { type: :object } }
          }
        run_test!
      end

      response "404", "Cliente não encontrado" do
        schema type: :object, properties: { error: { type: :string, example: "Not found" } }
        run_test!
      end
    end

    patch "Atualiza dados de um cliente" do
      tags "Clientes"
      description "Atualiza os dados cadastrais, telefones ou endereços de um cliente existente."
      operationId "updateCliente"
      consumes "application/json"
      produces "application/json"

      parameter name: :cliente_update, in: :body, schema: {
        type: :object,
        properties: {
          cliente: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Supermercado Progresso Matriz" },
              email: { type: :string, example: "financeiro@superprogresso.com.br" },
              data_ultima_visita: { type: :string, format: :date, example: "2026-11-08" }
            }
          }
        }
      }

      response "200", "Cliente atualizado com sucesso" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Cliente não encontrado" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove um cliente" do
      tags "Clientes"
      description "Exclui um cliente da base (apenas Administrador ou Secretaria). Retorna 422 se possuir ordens associadas com restrição."
      operationId "deleteCliente"
      produces "application/json"

      response "204", "Cliente removido com sucesso" do
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Cliente não encontrado" do
        schema type: :object
        run_test!
      end
    end
  end
end
