# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.openapi_root = Rails.root.join("swagger").to_s

  build_openapi_spec = lambda do |api_version|
    {
      openapi: "3.0.1",
      info: {
        title: "Ordem OS API",
        version: api_version,
        description: <<~DESC
          API REST para gerenciamento de Ordens de Serviço, Clientes, Equipamentos e Catálogo.

          ## Autenticação
          Esta API utiliza autenticação por **Bearer Token** via Sessões nativas do Rails 8.
          1. Efetue login em `POST /api/v1/login` informando seu CPF e senha.
          2. Copie o `token` retornado.
          3. Clique no botão verde **Authorize 🔓** no topo desta página e informe o token (ex: `Bearer seu_token` ou apenas `seu_token`).
          4. Todas as rotas protegidas passarão a enviar o header automaticamente.

          Desenvolvida em **Ruby on Rails 8.0** e **Ruby 3.4**.
        DESC
      },
      servers: [
        {
          url: "/",
          description: "Servidor Atual (Local / Ambiente Ativo)"
        },
        {
          url: "https://ordem-os-backend.onrender.com",
          description: "Ambiente de Produção (Render)"
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :token,
            description: "Token de autenticação retornado no login (/api/v1/login). Exemplo: Bearer <token> ou apenas <token>"
          }
        }
      },
      security: [
        { bearer_auth: [] }
      ],
      paths: {}
    }
  end

  # Define one or more Swagger documents and provide global metadata for each one
  config.openapi_specs = {
    "v1/swagger.yaml" => build_openapi_spec.call("v1")
  }

  config.openapi_format = :yaml
end
