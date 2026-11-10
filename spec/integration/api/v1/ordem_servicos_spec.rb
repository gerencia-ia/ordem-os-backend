# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Ordens de Serviço API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/ordem_servicos" do
    get "Lista ordens de serviço" do
      tags "Ordens de Serviço"
      description "Retorna a listagem de Ordens de Serviço. Administradores e Secretárias visualizam todas; Técnicos visualizam apenas as suas OSs atribuídas (Action Policy Scope)."
      operationId "getOrdemServicos"
      produces "application/json"

      parameter name: :cliente_id, in: :query, type: :integer, required: false, description: "Filtrar ordens por cliente"
      parameter name: :mes, in: :query, type: :integer, required: false, description: "Filtrar por mês do agendamento (1 a 12)"
      parameter name: :ano, in: :query, type: :integer, required: false, description: "Filtrar por ano do agendamento (ex: 2026)"

      response "200", "Lista de ordens de serviço retornada" do
        schema type: :array, items: { type: :object }
        run_test!
      end

      response "401", "Não autorizado" do
        schema type: :object, properties: { error: { type: :string, example: "Não autorizado" } }
        run_test!
      end
    end

    post "Abre uma nova ordem de serviço" do
      tags "Ordens de Serviço"
      description "Cria uma nova Ordem de Serviço com técnicos alocados, serviços orçados e equipamentos vinculados."
      operationId "createOrdemServico"
      consumes "application/json"
      produces "application/json"

      parameter name: :ordem_servico_params, in: :body, schema: {
        type: :object,
        properties: {
          ordem_servico: {
            type: :object,
            properties: {
              numero_ordem: { type: :string, example: "OS-2026-0150" },
              descricao: { type: :string, example: "Manutenção preventiva semestral e higienização química de condicionadores de ar." },
              tipo_servico: { type: :string, example: "Preventiva" },
              data_agendamento: { type: :string, format: :date_time, example: "2026-11-20T09:30:00Z" },
              data_vencimento: { type: :string, format: :date, example: "2026-11-25" },
              custo_estimado: { type: :string, example: "950.00" },
              valor_total: { type: :string, example: "950.00" },
              observacao: { type: :string, example: "Cliente solicita contato telefônico 30 minutos antes da chegada da equipe técnica." },
              cliente_id: { type: :integer, example: 1 },
              endereco_id: { type: :integer, example: 1 },
              prioridade_id: { type: :integer, example: 2 },
              status_id: { type: :integer, example: 1 },
              user_ids: {
                type: :array,
                description: "Lista de IDs dos técnicos responsáveis pela OS",
                items: { type: :integer },
                example: [2, 4]
              },
              servico_ids: {
                type: :array,
                description: "Lista de IDs dos serviços incluídos",
                items: { type: :integer },
                example: [1, 3]
              },
              equipamento_ids: {
                type: :array,
                description: "Lista de IDs dos equipamentos do cliente a serem atendidos",
                items: { type: :integer },
                example: [1]
              },
              os_equipamentos_attributes: {
                type: :array,
                description: "Laudo inicial ou específico por equipamento",
                items: {
                  type: :object,
                  properties: {
                    equipamento_id: { type: :integer, example: 1 },
                    laudo: { type: :string, example: "Constatado acúmulo de poeira nas aletas e necessidade de troca do capacitor." }
                  }
                }
              }
            },
            required: %w[numero_ordem cliente_id endereco_id prioridade_id status_id]
          }
        },
        required: %w[ordem_servico]
      }

      response "201", "Ordem de serviço criada com sucesso" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação nos campos da OS" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado (apenas Administradores e Secretárias podem criar OS)" do
        schema type: :object, properties: { error: { type: :string, example: "Acesso negado" } }
        run_test!
      end
    end
  end

  path "/api/v1/ordem_servicos/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único da Ordem de Serviço", example: 1

    get "Visualiza detalhes de uma ordem de serviço" do
      tags "Ordens de Serviço"
      description "Retorna as informações completas da Ordem de Serviço, incluindo técnicos, equipamentos, laudos e status."
      operationId "getOrdemServico"
      produces "application/json"

      response "200", "Ordem de serviço encontrada" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado (técnicos só podem ver OSs atribuídas a eles)" do
        schema type: :object
        run_test!
      end

      response "404", "Ordem de serviço não encontrada" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza dados de uma ordem de serviço" do
      tags "Ordens de Serviço"
      description "Atualiza campos da Ordem de Serviço (datas, valores, técnicos, serviços)."
      operationId "updateOrdemServico"
      consumes "application/json"
      produces "application/json"

      parameter name: :ordem_servico_update, in: :body, schema: {
        type: :object,
        properties: {
          ordem_servico: {
            type: :object,
            properties: {
              observacao: { type: :string, example: "Serviço reprogramado a pedido do cliente." },
              data_agendamento: { type: :string, format: :date_time, example: "2026-11-22T14:00:00Z" },
              valor_total: { type: :string, example: "1100.00" }
            }
          }
        }
      }

      response "200", "Ordem atualizada com sucesso" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end

    delete "Exclui uma ordem de serviço" do
      tags "Ordens de Serviço"
      description "Remove a Ordem de Serviço (restrito a Administradores e Secretárias)."
      operationId "deleteOrdemServico"
      produces "application/json"

      response "204", "Ordem excluída com sucesso" do
        run_test!
      end

      response "403", "Acesso negado (Técnicos não podem excluir ordens)" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/ordem_servicos/{id}/update_status" do
    parameter name: :id, in: :path, type: :integer, description: "ID da Ordem de Serviço", example: 1

    patch "Atualiza o status da ordem de serviço" do
      tags "Ordens de Serviço"
      description "Altera rapidamente o status da OS (ex: de 'Aberta' para 'Em Execução' ou 'Concluída'). Permitido para técnicos vinculados à OS."
      operationId "updateOrdemServicoStatus"
      consumes "application/json"
      produces "application/json"

      parameter name: :status_params, in: :body, schema: {
        type: :object,
        properties: {
          status_id: { type: :integer, description: "ID do novo status", example: 2 }
        },
        required: %w[status_id]
      }

      response "200", "Status da OS alterado com sucesso" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/ordem_servicos/{id}/equipamentos/{equipamento_id}/laudo" do
    parameter name: :id, in: :path, type: :integer, description: "ID da Ordem de Serviço", example: 1
    parameter name: :equipamento_id, in: :path, type: :integer, description: "ID do Equipamento", example: 1

    patch "Atualiza o laudo técnico do equipamento na OS" do
      tags "Ordens de Serviço"
      description "Registra ou atualiza o parecer/laudo técnico emitido para um equipamento específico dentro da OS."
      operationId "updateEquipamentoLaudo"
      consumes "application/json"
      produces "application/json"

      parameter name: :laudo_params, in: :body, schema: {
        type: :object,
        properties: {
          laudo: {
            type: :string,
            description: "Texto descritivo do laudo ou parecer técnico",
            example: "Efetuada substituição do sensor de temperatura e recarga completa de gás refrigerante. Equipamento em pleno funcionamento."
          }
        },
        required: %w[laudo]
      }

      response "200", "Laudo registrado com sucesso" do
        schema type: :object,
          properties: {
            id: { type: :integer, example: 5 },
            equipamento_id: { type: :integer, example: 1 },
            laudo: { type: :string },
            ordem_servico_id: { type: :integer, example: 1 }
          }
        run_test!
      end

      response "404", "Equipamento não encontrado nesta ordem de serviço" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/ordem_servicos/{id}/servicos" do
    parameter name: :id, in: :path, type: :integer, description: "ID da Ordem de Serviço", example: 1

    post "Adiciona um serviço à ordem de serviço" do
      tags "Ordens de Serviço"
      description "Vincula um serviço do catálogo à Ordem de Serviço com sua respectiva quantidade."
      operationId "addServicoToOrdem"
      consumes "application/json"
      produces "application/json"

      parameter name: :servico_params, in: :body, schema: {
        type: :object,
        properties: {
          servico_id: { type: :integer, description: "ID do serviço no catálogo", example: 2 },
          quantidade: { type: :integer, description: "Quantidade executada", example: 3 }
        },
        required: %w[servico_id]
      }

      response "201", "Serviço adicionado com sucesso" do
        schema type: :object
        run_test!
      end

      response "404", "Serviço não encontrado" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/ordem_servicos/{id}/servicos/{servico_id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID da Ordem de Serviço", example: 1
    parameter name: :servico_id, in: :path, type: :integer, description: "ID do Serviço a ser removido", example: 2

    delete "Remove um serviço da ordem de serviço" do
      tags "Ordens de Serviço"
      description "Desvincula um serviço da Ordem de Serviço."
      operationId "removeServicoFromOrdem"
      produces "application/json"

      response "204", "Serviço removido com sucesso" do
        run_test!
      end

      response "404", "Serviço não associado à ordem de serviço" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/ordem_servicos/{id}/tecnicos" do
    parameter name: :id, in: :path, type: :integer, description: "ID da Ordem de Serviço", example: 1

    post "Aloca um técnico na ordem de serviço" do
      tags "Ordens de Serviço"
      description "Atribui um usuário técnico para atendimento desta Ordem de Serviço."
      operationId "addTecnicoToOrdem"
      consumes "application/json"
      produces "application/json"

      parameter name: :tecnico_params, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer, description: "ID do técnico (usuário com perfil Técnico)", example: 2 }
        },
        required: %w[user_id]
      }

      response "201", "Técnico alocado com sucesso" do
        schema type: :object
        run_test!
      end

      response "200", "Técnico já estava alocado" do
        schema type: :object
        run_test!
      end

      response "404", "Técnico não encontrado" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/ordem_servicos/{id}/tecnicos/{user_id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID da Ordem de Serviço", example: 1
    parameter name: :user_id, in: :path, type: :integer, description: "ID do Técnico a ser removido", example: 2

    delete "Desvincula um técnico da ordem de serviço" do
      tags "Ordens de Serviço"
      description "Remove a atribuição de um técnico desta Ordem de Serviço."
      operationId "removeTecnicoFromOrdem"
      produces "application/json"

      response "204", "Técnico desvinculado com sucesso" do
        run_test!
      end

      response "404", "Técnico não associado à ordem de serviço" do
        schema type: :object
        run_test!
      end
    end
  end
end
