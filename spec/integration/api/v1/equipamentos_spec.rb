# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Equipamentos API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/equipamentos" do
    get "Lista equipamentos" do
      tags "Equipamentos"
      description "Retorna todos os equipamentos cadastrados, com opção de filtrar por cliente."
      operationId "getEquipamentos"
      produces "application/json"

      parameter name: :cliente_id, in: :query, type: :integer, required: false, description: "Filtrar equipamentos por ID do cliente"

      response "200", "Lista de equipamentos retornada" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              marca: { type: :string, example: "Daikin" },
              btus: { type: :integer, example: 18000 },
              local_instalacao: { type: :string, example: "Escritório Diretoria" },
              observacao: { type: :string, example: "Instalado em 2024" },
              cliente_id: { type: :integer, example: 1 }
            }
          }
        run_test!
      end
    end

    post "Cadastra um novo equipamento" do
      tags "Equipamentos"
      description "Cadastra um novo equipamento associado a um cliente existente."
      operationId "createEquipamento"
      consumes "application/json"
      produces "application/json"

      parameter name: :equipamento_params, in: :body, schema: {
        type: :object,
        properties: {
          equipamento: {
            type: :object,
            properties: {
              marca: { type: :string, example: "Springer Midea Inverter" },
              btus: { type: :integer, example: 12000 },
              local_instalacao: { type: :string, example: "Sala de Reuniões 02" },
              observacao: { type: :string, example: "Voltagem 220V monofásica" },
              cliente_id: { type: :integer, example: 1 }
            },
            required: %w[marca btus cliente_id]
          }
        },
        required: %w[equipamento]
      }

      response "201", "Equipamento cadastrado com sucesso" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/equipamentos/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único do Equipamento", example: 1

    get "Visualiza detalhes de um equipamento" do
      tags "Equipamentos"
      operationId "getEquipamento"
      produces "application/json"

      response "200", "Equipamento encontrado" do
        schema type: :object
        run_test!
      end

      response "404", "Equipamento não encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza dados de um equipamento" do
      tags "Equipamentos"
      operationId "updateEquipamento"
      consumes "application/json"
      produces "application/json"

      parameter name: :equipamento_update, in: :body, schema: {
        type: :object,
        properties: {
          equipamento: {
            type: :object,
            properties: {
              marca: { type: :string, example: "Daikin Inverter Advance" },
              btus: { type: :integer, example: 18000 },
              local_instalacao: { type: :string, example: "Sala TI / Servidores" }
            }
          }
        }
      }

      response "200", "Equipamento atualizado" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove um equipamento" do
      tags "Equipamentos"
      operationId "deleteEquipamento"
      produces "application/json"

      response "204", "Equipamento removido com sucesso" do
        run_test!
      end
    end
  end

  path "/api/v1/equipamentos/{id}/historico_laudos" do
    parameter name: :id, in: :path, type: :integer, description: "ID do Equipamento", example: 1

    get "Histórico de laudos do equipamento em todas as ordens de serviço" do
      tags "Equipamentos"
      description "Retorna a linha do tempo completa de todos os laudos e pareceres técnicos já emitidos para este equipamento em todas as ordens de serviço atendidas."
      operationId "getHistoricoLaudosEquipamento"
      produces "application/json"

      response "200", "Histórico retornado com sucesso em ordem decrescente de atendimento" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 12 },
              laudo: { type: :string, example: "Higienização completa da serpentina e troca do capacitor do motor do ventilador." },
              created_at: { type: :string, format: :date_time },
              updated_at: { type: :string, format: :date_time },
              ordem_servico: {
                type: :object,
                properties: {
                  id: { type: :integer, example: 3 },
                  numero_ordem: { type: :string, example: "OS-2026-0044" },
                  descricao: { type: :string, example: "Manutenção periódica" },
                  data_agendamento: { type: :string, format: :date_time },
                  data_fechamento: { type: :string, format: :date_time },
                  status: { type: :string, example: "Finalizada" },
                  prioridade: { type: :string, example: "Normal" }
                }
              }
            }
          }
        run_test!
      end
    end
  end
end
