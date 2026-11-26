# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Orcamentos", type: :request do
  let!(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let!(:role_secretaria) { Role.find_or_create_by!(nome: "Secretaria") }
  let!(:role_tecnico) { Role.find_or_create_by!(nome: "Técnico") }

  let!(:admin) do
    User.create!(
      nome: "Admin",
      cpf: "11111111111",
      email: "admin_orc@test.com",
      password: "password123",
      role: role_admin
    )
  end

  let!(:secretaria) do
    User.create!(
      nome: "Secretaria",
      cpf: "22222222222",
      email: "sec_orc@test.com",
      password: "password123",
      role: role_secretaria
    )
  end

  let!(:tecnico) do
    User.create!(
      nome: "Tecnico",
      cpf: "33333333333",
      email: "tec_orc@test.com",
      password: "password123",
      role: role_tecnico
    )
  end

  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Teste",
      email: "cliente_orc@teste.com",
      enderecos_attributes: [
        { rua: "Rua 1", numero: "100", bairro: "Centro", cidade: "Cidade", cep: "12345000" }
      ],
      telefones_attributes: [
        { numero: "11999999999" }
      ]
    )
  end

  let!(:andar) { Andar.create!(descricao: "Térreo") }
  let!(:categoria) { CategoriasServico.create!(descricao: "Limpeza") }
  let!(:servico) { Servico.create!(nome: "Limpeza Split", tempo_servico: 90, categorias_servico: categoria) }
  let!(:valor_por_andar) { ValorPorAndar.create!(servico: servico, andar: andar, valor: 150.0) }
  let!(:material) { Material.create!(nome: "Gás R410A", valor_referencia: 140.0) }
  let!(:equipamento) do
    Equipamento.create!(
      cliente: cliente,
      andar: andar,
      marca: "Daikin",
      btus: "18000",
      local_instalacao: "Escritório"
    )
  end

  let!(:status_inicial) { Status.find_or_create_by!(nome: "Não iniciada") }
  let!(:prioridade_media) { Prioridade.find_or_create_by!(descricao: "Média") }
  let!(:prioridade_alta) { Prioridade.find_or_create_by!(descricao: "Alta") }

  def auth_header(user)
    session = user.sessions.create!
    { "Authorization" => "Bearer #{session.token}" }
  end

  describe "Autorização" do
    it "retorna 401 quando não autenticado" do
      get "/api/v1/orcamentos"
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 403 para Técnico em todas as ações" do
      orcamento = Orcamento.create!(cliente: cliente, endereco: cliente.enderecos.first, status: "aprovado")

      get "/api/v1/orcamentos", headers: auth_header(tecnico)
      expect(response).to have_http_status(:forbidden)

      post "/api/v1/orcamentos", params: { orcamento: { cliente_id: cliente.id, endereco_id: cliente.enderecos.first.id } }, headers: auth_header(tecnico)
      expect(response).to have_http_status(:forbidden)

      post "/api/v1/orcamentos/#{orcamento.id}/converter_em_os", headers: auth_header(tecnico)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "CRUD de Orçamentos" do
    let(:payload_criacao) do
      {
        orcamento: {
          cliente_id: cliente.id,
          endereco_id: cliente.enderecos.first.id,
          status: "enviado",
          data_validade: "2026-12-31",
          desconto: 40.0,
          condicoes_pagamento: "50% entrada e 50% na entrega",
          observacao: "Atendimento em horário comercial",
          equipamento_ids: [ equipamento.id ],
          orcamento_servicos_attributes: [
            { equipamento_id: equipamento.id, valor_por_andar_id: valor_por_andar.id, quantidade: 2 }
          ],
          orcamento_materiais_attributes: [
            { material_id: material.id },
            { nome_material: "Cabo PP", valor: 30.0 }
          ]
        }
      }
    end

    it "permite que Secretaria crie, liste, visualize, atualize e exclua orçamento" do
      post "/api/v1/orcamentos", params: payload_criacao, headers: auth_header(secretaria), as: :json
      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["numero_orcamento"]).to start_with("ORC-")
      expect(body["status"]).to eq("enviado")
      expect(body["subtotal_servicos"].to_f).to eq(300.0)
      expect(body["subtotal_materiais"].to_f).to eq(170.0)
      expect(body["valor_total"].to_f).to eq(430.0)
      expect(body["equipamentos"].size).to eq(1)
      expect(body["servicos"].size).to eq(1)
      expect(body["materiais"].size).to eq(2)

      orcamento_id = body["id"]

      get "/api/v1/orcamentos?status=enviado&cliente_id=#{cliente.id}", headers: auth_header(secretaria)
      expect(response).to have_http_status(:ok)
      lista = JSON.parse(response.body)
      expect(lista.map { |o| o["id"] }).to include(orcamento_id)

      get "/api/v1/orcamentos/#{orcamento_id}", headers: auth_header(secretaria)
      expect(response).to have_http_status(:ok)

      servico_item_id = body["servicos"].first["id"]
      patch "/api/v1/orcamentos/#{orcamento_id}", params: {
        orcamento: {
          desconto: 10.0,
          orcamento_servicos_attributes: [
            { id: servico_item_id, _destroy: true }
          ]
        }
      }, headers: auth_header(secretaria), as: :json
      expect(response).to have_http_status(:ok)
      atualizado = JSON.parse(response.body)
      expect(atualizado["subtotal_servicos"].to_f).to eq(0.0)
      expect(atualizado["valor_total"].to_f).to eq(160.0)

      delete "/api/v1/orcamentos/#{orcamento_id}", headers: auth_header(secretaria)
      expect(response).to have_http_status(:no_content)
      expect(Orcamento.find_by(id: orcamento_id)).to be_nil
    end
  end

  describe "PATCH /api/v1/orcamentos/:id/update_status" do
    it "atualiza para status válidos e rejeita status inválidos ou convertido manual" do
      orcamento = Orcamento.create!(cliente: cliente, endereco: cliente.enderecos.first, status: "rascunho")

      patch "/api/v1/orcamentos/#{orcamento.id}/update_status", params: { status: "aprovado" }, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
      expect(orcamento.reload.status).to eq("aprovado")

      patch "/api/v1/orcamentos/#{orcamento.id}/update_status", params: { status: "convertido" }, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)

      patch "/api/v1/orcamentos/#{orcamento.id}/update_status", params: { status: "inexistente" }, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /api/v1/orcamentos/:id/converter_em_os" do
    let!(:orcamento) do
      Orcamento.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        status: "aprovado",
        observacao: "Cliente prefere manhã",
        equipamento_ids: [ equipamento.id ],
        orcamento_servicos_attributes: [
          { equipamento_id: equipamento.id, valor_por_andar_id: valor_por_andar.id, quantidade: 2 }
        ],
        orcamento_materiais_attributes: [
          { material_id: material.id }
        ]
      )
    end

    it "converte orçamento aprovado em Ordem de Serviço preservando itens, snapshots e bloqueando edição/nova conversão" do
      post "/api/v1/orcamentos/#{orcamento.id}/converter_em_os",
           params: {
             prioridade_id: prioridade_alta.id,
             data_agendamento: "2026-12-01T09:00:00Z",
             tecnico_ids: [ tecnico.id ]
           },
           headers: auth_header(admin),
           as: :json

      expect(response).to have_http_status(:created)
      os_body = JSON.parse(response.body)

      expect(os_body["numero_ordem"]).to start_with("OS-")
      expect(os_body["cliente"]["id"]).to eq(cliente.id)
      expect(os_body["prioridade"]["id"]).to eq(prioridade_alta.id)
      expect(os_body["valor_total"].to_f).to eq(440.0)
      expect(os_body["equipamentos"].size).to eq(1)
      expect(os_body["servicos"].size).to eq(1)
      expect(os_body["servicos"].first["quantidade"]).to eq(2)
      expect(os_body["materiais"].size).to eq(1)
      expect(os_body["tecnicos"].map { |t| t["id"] }).to include(tecnico.id)

      orcamento.reload
      expect(orcamento.status).to eq("convertido")
      expect(orcamento.ordem_servico_id).to eq(os_body["id"])

      # Bloqueia conversão duplicada
      post "/api/v1/orcamentos/#{orcamento.id}/converter_em_os", headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)

      # Bloqueia edição e exclusão de orçamento convertido
      patch "/api/v1/orcamentos/#{orcamento.id}", params: { orcamento: { observacao: "Alterado" } }, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)

      delete "/api/v1/orcamentos/#{orcamento.id}", headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)

      # Ao excluir a OS, o orçamento permanece com ordem_servico_id nil (on_delete: :nullify)
      OrdemServico.find(os_body["id"]).destroy!
      expect(orcamento.reload.ordem_servico_id).to be_nil
    end

    it "rejeita conversão quando orçamento não está aprovado" do
      orc_rascunho = Orcamento.create!(cliente: cliente, endereco: cliente.enderecos.first, status: "rascunho")

      post "/api/v1/orcamentos/#{orc_rascunho.id}/converter_em_os", headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
