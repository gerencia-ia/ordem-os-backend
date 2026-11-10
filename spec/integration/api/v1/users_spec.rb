# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Usuários API", type: :request, swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/users" do
    get "Lista usuários do sistema" do
      tags "Usuários"
      description "Retorna a lista de usuários e seus respectivos papéis. Restrito a Administradores e Secretárias."
      operationId "getUsers"
      produces "application/json"

      response "200", "Lista de usuários retornada" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              nome: { type: :string, example: "Letícia Andreia" },
              cpf: { type: :string, example: "33333333333" },
              email: { type: :string, example: "leticia@example.com" },
              telefone: { type: :string, example: "11997499375" },
              role_id: { type: :integer, example: 3 },
              role: {
                type: :object,
                properties: {
                  id: { type: :integer, example: 3 },
                  nome: { type: :string, example: "Administrador" }
                }
              }
            }
          }
        run_test!
      end

      response "403", "Acesso negado (Técnicos não podem listar todos os usuários)" do
        schema type: :object
        run_test!
      end
    end

    post "Cadastra um novo usuário" do
      tags "Usuários"
      description "Cria um novo usuário e define seu papel no sistema (apenas Administradores)."
      operationId "createUser"
      consumes "application/json"
      produces "application/json"

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Rodrigo Mendonça" },
              cpf: { type: :string, example: "66677788899" },
              email: { type: :string, example: "rodrigo.tecnico@example.com" },
              telefone: { type: :string, example: "11987654321" },
              password: { type: :string, example: "senhaSegura#2026" },
              role_id: { type: :integer, description: "1: Secretaria, 2: Técnico, 3: Administrador", example: 2 }
            },
            required: %w[nome cpf password role_id]
          }
        },
        required: %w[user]
      }

      response "201", "Usuário criado com sucesso" do
        schema type: :object
        run_test!
      end

      response "422", "Erro de validação (ex: CPF já cadastrado ou campos faltantes)" do
        schema type: :object
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end
  end

  path "/api/v1/users/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID único do Usuário", example: 1

    get "Visualiza detalhes de um usuário" do
      tags "Usuários"
      operationId "getUser"
      produces "application/json"

      response "200", "Usuário localizado" do
        schema type: :object
        run_test!
      end

      response "404", "Usuário não encontrado" do
        schema type: :object
        run_test!
      end
    end

    patch "Atualiza dados de um usuário" do
      tags "Usuários"
      description "Atualiza informações do usuário. Apenas Administradores podem alterar o role_id; usuários comuns só podem editar seus próprios dados básicos (telefone, email, senha)."
      operationId "updateUser"
      consumes "application/json"
      produces "application/json"

      parameter name: :user_update, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              nome: { type: :string, example: "Rodrigo Mendonça Jr" },
              telefone: { type: :string, example: "11999998888" },
              email: { type: :string, example: "rodrigo.novo@example.com" },
              password: { type: :string, example: "novaSenha#2026" },
              role_id: { type: :integer, example: 2 }
            }
          }
        }
      }

      response "200", "Usuário atualizado" do
        schema type: :object
        run_test!
      end
    end

    delete "Remove um usuário" do
      tags "Usuários"
      description "Exclui um usuário do sistema (apenas Administradores, não sendo permitido auto-exclusão)."
      operationId "deleteUser"
      produces "application/json"

      response "204", "Usuário excluído" do
        run_test!
      end

      response "403", "Acesso negado" do
        schema type: :object
        run_test!
      end
    end
  end
end
