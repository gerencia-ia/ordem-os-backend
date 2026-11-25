# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::OrdemServicoEquipamentos", type: :request do
  let!(:role_admin) { Role.find_or_create_by!(nome: "Administrador") }
  let!(:role_secretaria) { Role.find_or_create_by!(nome: "Secretaria") }
  let!(:role_tecnico) { Role.find_or_create_by!(nome: "Técnico") }

  let!(:admin) do
    User.create!(
      nome: "Admin Teste",
      cpf: "11111111111",
      email: "admin_equip@teste.com",
      password: "password123",
      role: role_admin
    )
  end

  let!(:secretaria) do
    User.create!(
      nome: "Secretaria Teste",
      cpf: "22222222222",
      email: "secretaria_equip@teste.com",
      password: "password123",
      role: role_secretaria
    )
  end

  let!(:tecnico) do
    User.create!(
      nome: "Tecnico Teste",
      cpf: "33333333333",
      email: "tecnico_equip@teste.com",
      password: "password123",
      role: role_tecnico
    )
  end

  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente OS Equip",
      enderecos_attributes: [ { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41999998888" } ]
    )
  end

  let!(:outro_cliente) do
    Cliente.create!(
      nome: "Outro Cliente OS Equip",
      enderecos_attributes: [ { rua: "Rua B", numero: "20", bairro: "Batel", cidade: "Curitiba" } ],
      telefones_attributes: [ { numero: "41988887777" } ]
    )
  end

  let!(:prioridade) { Prioridade.create!(descricao: "Alta") }
  let!(:status_aberta) { Status.create!(nome: "Aberta") }
  let!(:status_concluida) { Status.create!(nome: "Concluída") }
  let!(:status_cancelada) { Status.create!(nome: "Cancelada") }
  let!(:andar) { Andar.create!(descricao: "1º Andar") }

  let!(:equipamento_cliente) do
    cliente.equipamentos.create!(marca: "Daikin", local_instalacao: "Sala", andar: andar)
  end

  let!(:equipamento_outro_cliente) do
    outro_cliente.equipamentos.create!(marca: "LG", local_instalacao: "Quarto", andar: andar)
  end

  let!(:ordem_servico) do
    os = OrdemServico.create!(
      cliente: cliente,
      endereco: cliente.enderecos.first,
      prioridade: prioridade,
      status: status_aberta
    )
    os.os_tecnicos.create!(user: tecnico)
    os
  end

  def auth_header(user)
    session = user.sessions.create!
    { "Authorization" => "Bearer #{session.token}" }
  end

  describe "POST /api/v1/ordem_servicos/:id/equipamentos" do
    it "retorna 401 quando enviado sem token" do
      post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos", params: { equipamento_id: equipamento_cliente.id }
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 403 quando usuário é Técnico" do
      post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos",
           params: { equipamento_id: equipamento_cliente.id },
           headers: auth_header(tecnico)
      expect(response).to have_http_status(:forbidden)
    end

    it "vincula um equipamento do cliente à OS e retorna 201 com a OS atualizada" do
      expect {
        post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos",
             params: { equipamento_id: equipamento_cliente.id },
             headers: auth_header(secretaria)
      }.to change(OsEquipamento, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      equipamentos_ids = body["equipamentos"].map { |e| e["equipamento_id"] }
      expect(equipamentos_ids).to include(equipamento_cliente.id)
    end

    it "retorna 404 quando o equipamento não existe" do
      post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos",
           params: { equipamento_id: 999_999 },
           headers: auth_header(admin)

      expect(response).to have_http_status(:not_found)
    end

    it "retorna 422 quando o equipamento pertence a outro cliente" do
      post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos",
           params: { equipamento_id: equipamento_outro_cliente.id },
           headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "retorna 422 quando o equipamento já está vinculado à OS" do
      ordem_servico.os_equipamentos.create!(equipamento: equipamento_cliente)

      post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos",
           params: { equipamento_id: equipamento_cliente.id },
           headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "retorna 422 quando a OS está concluída" do
      ordem_servico.update!(status: status_concluida)

      post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos",
           params: { equipamento_id: equipamento_cliente.id },
           headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "retorna 422 quando a OS está cancelada" do
      ordem_servico.update!(status: status_cancelada)

      post "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos",
           params: { equipamento_id: equipamento_cliente.id },
           headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/ordem_servicos/:id/equipamentos/:equipamento_id" do
    before do
      ordem_servico.os_equipamentos.create!(equipamento: equipamento_cliente)
    end

    it "retorna 403 quando usuário é Técnico" do
      delete "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos/#{equipamento_cliente.id}",
             headers: auth_header(tecnico)
      expect(response).to have_http_status(:forbidden)
    end

    it "remove o equipamento da OS e retorna 204" do
      expect {
        delete "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos/#{equipamento_cliente.id}",
               headers: auth_header(admin)
      }.to change(OsEquipamento, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "retorna 404 quando o equipamento não está vinculado à OS" do
      delete "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos/#{equipamento_outro_cliente.id}",
             headers: auth_header(admin)

      expect(response).to have_http_status(:not_found)
    end

    it "retorna 422 quando existem serviços vinculados ao equipamento na OS" do
      servico = Servico.create!(nome: "Limpeza")
      valor_por_andar = ValorPorAndar.create!(servico: servico, andar: andar, valor: 120.0)
      ordem_servico.os_servicos.create!(equipamento: equipamento_cliente, valor_por_andar: valor_por_andar)

      expect {
        delete "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos/#{equipamento_cliente.id}",
               headers: auth_header(admin)
      }.not_to change(OsEquipamento, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "retorna 422 quando a OS está concluída" do
      ordem_servico.update!(status: status_concluida)

      delete "/api/v1/ordem_servicos/#{ordem_servico.id}/equipamentos/#{equipamento_cliente.id}",
             headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
