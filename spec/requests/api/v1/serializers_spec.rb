# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Serializers Standardization", type: :request do
  let!(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let!(:role_tecnico) { Role.find_or_create_by!(nome: "Técnico") }

  let!(:admin) do
    User.create!(
      nome: "Admin Teste",
      cpf: "11111111111",
      email: "admin@teste.com",
      telefone: "11999999999",
      password: "password123",
      role: role_admin
    )
  end

  let!(:tecnico1) do
    User.create!(
      nome: "Gabriel Técnico",
      cpf: "22222222222",
      email: "gabriel@teste.com",
      telefone: "73926141694",
      password: "password123",
      role: role_tecnico
    )
  end

  let!(:tecnico2) do
    User.create!(
      nome: "Cauã Técnico",
      cpf: "33333333333",
      email: "caua@teste.com",
      telefone: "11888888888",
      password: "password123",
      role: role_tecnico
    )
  end

  let!(:cliente) do
    Cliente.create!(
      nome: "Empresa Climatizada Ltda",
      email: "contato@climatizada.com",
      data_registro: "2026-01-15",
      data_ultima_visita: "2026-06-20",
      enderecos_attributes: [
        { rua: "Av. Paulista", numero: "1000", bairro: "Bela Vista", cidade: "São Paulo", cep: "01310100" }
      ],
      telefones_attributes: [
        { numero: "11988887777" }
      ]
    )
  end

  let!(:equipamento) do
    cliente.equipamentos.create!(
      marca: "Daikin Inverter",
      btus: 18000,
      local_instalacao: "Sala de Reuniões",
      observacao: "220V"
    )
  end

  let!(:categoria) { CategoriasServico.create!(descricao: "Preventiva") }
  let!(:servico) do
    Servico.create!(
      nome: "Higienização Química",
      valor: 250.0,
      tempo_servico: 90,
      categorias_servico: categoria
    )
  end

  let!(:prioridade) { Prioridade.create!(descricao: "Alta") }
  let!(:status_aberta) { Status.create!(nome: "Aberta") }

  let!(:ordem_servico) do
    os = OrdemServico.create!(
      numero_ordem: "OS-2026-9001",
      descricao: "Manutenção completa",
      cliente: cliente,
      endereco: cliente.enderecos.first,
      prioridade: prioridade,
      status: status_aberta,
      custo_estimado: 250.0,
      valor_total: 250.0
    )
    os.os_tecnicos.create!(user: tecnico1)
    os.os_tecnicos.create!(user: tecnico2)
    os.os_servicos.create!(servico: servico, quantidade: 2)
    os.os_equipamentos.create!(equipamento: equipamento, laudo: "Aparelho limpo e revisado com sucesso.")
    os
  end

  def auth_header(user)
    session = user.sessions.create!
    { "Authorization" => "Bearer #{session.token}" }
  end

  describe "GET /api/v1/ordem_servicos/:id" do
    it "serializa tecnicos como array e inclui tecnico_responsavel" do
      get "/api/v1/ordem_servicos/#{ordem_servico.id}", headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      # Array de técnicos
      expect(body["tecnicos"]).to be_an(Array)
      expect(body["tecnicos"].size).to eq(2)
      tecnico_ids = body["tecnicos"].map { |t| t["id"] }
      expect(tecnico_ids).to include(tecnico1.id, tecnico2.id)

      # Técnico responsável aponta para o primeiro da lista
      expect(body["tecnico_responsavel"]).to be_a(Hash)
      expect(body["tecnico_responsavel"]["id"]).to eq(tecnico1.id)
      expect(body["tecnico_responsavel"]["nome"]).to eq(tecnico1.nome)

      # Timestamps presentes em OrdemServico
      expect(body).to have_key("created_at")
      expect(body).to have_key("updated_at")

      # Serviços vinculados com quantidade
      expect(body["servicos"]).to be_an(Array)
      expect(body["servicos"].first["nome"]).to eq("Higienização Química")
      expect(body["servicos"].first["quantidade"]).to eq(2)
      expect(body["servicos"].first["categoria"]["descricao"]).to eq("Preventiva")

      # Equipamentos vinculados com laudo
      expect(body["equipamentos"]).to be_an(Array)
      expect(body["equipamentos"].first["marca"]).to eq("Daikin Inverter")
      expect(body["equipamentos"].first["laudo"]).to eq("Aparelho limpo e revisado com sucesso.")

      # Cliente e endereço aninhados
      expect(body["cliente"]["nome"]).to eq("Empresa Climatizada Ltda")
      expect(body["endereco"]["rua"]).to eq("Av. Paulista")
    end
  end

  describe "GET /api/v1/clientes/:id" do
    it "serializa telefones e enderecos mas omite timestamps" do
      get "/api/v1/clientes/#{cliente.id}", headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body["nome"]).to eq("Empresa Climatizada Ltda")
      expect(body["telefones"]).to be_an(Array)
      expect(body["telefones"].first["numero"]).to eq("11988887777")
      expect(body["enderecos"]).to be_an(Array)
      expect(body["enderecos"].first["rua"]).to eq("Av. Paulista")

      # Conforme orientação do usuário: timestamps somente em OrdemServico
      expect(body).not_to have_key("created_at")
      expect(body).not_to have_key("updated_at")
    end
  end

  describe "GET /api/v1/users/:id" do
    it "serializa atributos do usuário com role e sem timestamps" do
      get "/api/v1/users/#{tecnico1.id}", headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body["nome"]).to eq("Gabriel Técnico")
      expect(body["role"]["nome"]).to eq("Técnico")

      # Timestamps somente em OrdemServico
      expect(body).not_to have_key("created_at")
      expect(body).not_to have_key("updated_at")
    end
  end

  describe "GET /api/v1/equipamentos/:id/historico_laudos" do
    it "utiliza HistoricoLaudoSerializer para formatar os laudos anteriores" do
      get "/api/v1/equipamentos/#{equipamento.id}/historico_laudos", headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body).to be_an(Array)
      expect(body.first["laudo"]).to eq("Aparelho limpo e revisado com sucesso.")
      expect(body.first["ordem_servico"]["numero_ordem"]).to eq("OS-2026-9001")
      expect(body.first["ordem_servico"]["status"]).to eq("Aberta")
      expect(body.first["ordem_servico"]["prioridade"]).to eq("Alta")
    end
  end
end
