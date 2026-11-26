# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Orçamentos API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/orcamentos" do
    get "Lista orçamentos" do
      tags "Orçamentos"
      description "Retorna a lista de orçamentos cadastrados (Administrador e Secretaria)."
      operationId "getOrcamentos"
      produces "application/json"

      parameter name: :cliente_id, in: :query, type: :integer, required: false, description: "Filtrar por cliente"
      parameter name: :status, in: :query, type: :string, required: false, description: "Filtrar por status"
      parameter name: :mes, in: :query, type: :integer, required: false, description: "Filtrar por mês de criação (1 a 12)"
      parameter name: :ano, in: :query, type: :integer, required: false, description: "Filtrar por ano de criação"

      response "200", "Lista de orçamentos retornada" do
        schema type: :array, items: { type: :object }
        run_test!
      end

      response "401", "Não autorizado" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end

    post "Cria um novo orçamento" do
      tags "Orçamentos"
      description "Cria um novo orçamento vinculado a cliente, endereço, equipamentos, serviços por andar e materiais."
      operationId "createOrcamento"
      consumes "application/json"
      produces "application/json"

      parameter name: :orcamento_params, in: :body, schema: {
        type: :object,
        properties: {
          orcamento: {
            type: :object,
            properties: {
              cliente_id: { type: :integer, example: 1 },
              endereco_id: { type: :integer, example: 1 },
              status: { type: :string, example: "rascunho" },
              data_validade: { type: :string, format: :date, nullable: true, example: "2026-12-31" },
              desconto: { type: :number, format: :decimal, example: 50.0 },
              condicoes_pagamento: { type: :string, nullable: true, example: "50% entrada e 50% na entrega" },
              observacao: { type: :string, nullable: true, example: "Orçamento válido por 15 dias." },
              equipamento_ids: {
                type: :array,
                items: { type: :integer },
                example: [ 1 ]
              },
              orcamento_servicos_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    equipamento_id: { type: :integer, example: 1 },
                    valor_por_andar_id: { type: :integer, example: 1 },
                    quantidade: { type: :integer, example: 1 }
                  }
                }
              },
              orcamento_materiais_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    material_id: { type: :integer, nullable: true, example: 1 },
                    nome_material: { type: :string, example: "Gás refrigerante R410A" },
                    valor: { type: :number, format: :decimal, example: 140.0 }
                  }
                }
              }
            },
            required: %w[cliente_id endereco_id]
          }
        },
        required: %w[orcamento]
      }

      response "201", "Orçamento criado com sucesso" do
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

  path "/api/v1/orcamentos/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID do Orçamento", example: 1

    get "Visualiza detalhes de um orçamento" do
      tags "Orçamentos"
      operationId "getOrcamento"
      produces "application/json"

      response "200", "Orçamento encontrado" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Orçamento não encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza um orçamento" do
      tags "Orçamentos"
      operationId "updateOrcamento"
      consumes "application/json"
      produces "application/json"

      parameter name: :orcamento_update, in: :body, schema: {
        type: :object,
        properties: {
          orcamento: {
            type: :object,
            properties: {
              desconto: { type: :number, format: :decimal, example: 30.0 },
              data_validade: { type: :string, format: :date, example: "2026-12-31" },
              observacao: { type: :string, example: "Observação atualizada" }
            }
          }
        }
      }

      response "200", "Orçamento atualizado" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Orçamento não encontrado" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação ou orçamento já convertido" do
        schema type: :object
        run_test!
      end
    end

    delete "Exclui um orçamento" do
      tags "Orçamentos"
      operationId "deleteOrcamento"
      produces "application/json"

      response "204", "Orçamento excluído" do
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "404", "Orçamento não encontrado" do
        schema type: :object
        run_test!
      end

      response "422", "Orçamento já convertido não pode ser excluído" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/orcamentos/{id}/update_status" do
    parameter name: :id, in: :path, type: :integer, description: "ID do Orçamento", example: 1

    patch "Atualiza o status do orçamento" do
      tags "Orçamentos"
      operationId "updateOrcamentoStatus"
      consumes "application/json"
      produces "application/json"

      parameter name: :status_params, in: :body, schema: {
        type: :object,
        properties: {
          status: { type: :string, example: "aprovado" }
        },
        required: %w[status]
      }

      response "200", "Status atualizado" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "422", "Status inválido ou orçamento já convertido" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/orcamentos/{id}/converter_em_os" do
    parameter name: :id, in: :path, type: :integer, description: "ID do Orçamento", example: 1

    post "Converte um orçamento aprovado em Ordem de Serviço" do
      tags "Orçamentos"
      operationId "converterOrcamentoEmOs"
      consumes "application/json"
      produces "application/json"

      parameter name: :converter_params, in: :body, schema: {
        type: :object,
        properties: {
          prioridade_id: { type: :integer, nullable: true, example: 2 },
          status_id: { type: :integer, nullable: true, example: 1 },
          data_agendamento: { type: :string, format: :date_time, nullable: true, example: "2026-12-01T09:00:00Z" },
          descricao: { type: :string, nullable: true },
          observacao: { type: :string, nullable: true },
          tecnico_ids: {
            type: :array,
            items: { type: :integer },
            example: [ 2 ]
          }
        }
      }

      response "201", "Ordem de Serviço criada a partir do orçamento" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end

      response "422", "Orçamento não aprovado ou já convertido" do
        schema type: :object
        run_test!
      end
    end
  end
end
