# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orcamento, type: :model do
  let!(:cliente) do
    Cliente.create!(
      nome: "Cliente Orçamento",
      email: "orc@teste.com",
      enderecos_attributes: [
        { rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Cidade", cep: "12345000" }
      ],
      telefones_attributes: [
        { numero: "11999999999" }
      ]
    )
  end

  let!(:outro_cliente) do
    Cliente.create!(
      nome: "Outro Cliente",
      enderecos_attributes: [
        { rua: "Rua B", numero: "20", bairro: "Bairro", cidade: "Cidade" }
      ],
      telefones_attributes: [
        { numero: "11988888888" }
      ]
    )
  end

  let!(:andar) { Andar.create!(descricao: "1º Andar") }
  let!(:categoria) { CategoriasServico.create!(descricao: "Instalação") }
  let!(:servico) { Servico.create!(nome: "Instalação Split", tempo_servico: 120, categorias_servico: categoria) }
  let!(:valor_por_andar) { ValorPorAndar.create!(servico: servico, andar: andar, valor: 350.0) }
  let!(:material) { Material.create!(nome: "Gás R410A", valor_referencia: 140.0) }

  let!(:equipamento) do
    Equipamento.create!(
      cliente: cliente,
      andar: andar,
      marca: "LG",
      btus: "12000",
      local_instalacao: "Sala"
    )
  end

  let!(:equipamento_outro) do
    Equipamento.create!(
      cliente: outro_cliente,
      andar: andar,
      marca: "Samsung",
      btus: "9000",
      local_instalacao: "Quarto"
    )
  end

  describe "geração automática de número e valores padrão" do
    it "gera numero_orcamento no formato ORC-YYYYMMDD-XXXX e status padrão rascunho" do
      orcamento = Orcamento.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first
      )

      expect(orcamento.numero_orcamento).to match(/\AORC-\d{8}-[A-Z0-9]{4}\z/)
      expect(orcamento.status).to eq("rascunho")
      expect(orcamento.desconto.to_f).to eq(0.0)
      expect(orcamento.valor_total.to_f).to eq(0.0)
    end
  end

  describe "cálculo automático de subtotais, desconto e valor_total" do
    it "calcula subtotal_servicos, subtotal_materiais e valor_total com desconto" do
      orcamento = Orcamento.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        desconto: 50.0,
        equipamento_ids: [ equipamento.id ],
        orcamento_servicos_attributes: [
          { equipamento_id: equipamento.id, valor_por_andar_id: valor_por_andar.id, quantidade: 2 }
        ],
        orcamento_materiais_attributes: [
          { material_id: material.id },
          { nome_material: "Suporte Avulso", valor: 80.0 }
        ]
      )

      expect(orcamento.subtotal_servicos.to_f).to eq(700.0)
      expect(orcamento.subtotal_materiais.to_f).to eq(220.0)
      expect(orcamento.valor_total.to_f).to eq(870.0)

      item_servico = orcamento.orcamento_servicos.first
      expect(item_servico.nome_servico).to eq("Instalação Split")
      expect(item_servico.valor_unitario.to_f).to eq(350.0)

      item_catalogo = orcamento.orcamento_materiais.find_by(material_id: material.id)
      expect(item_catalogo.nome_material).to eq("Gás R410A")
      expect(item_catalogo.valor.to_f).to eq(140.0)
    end

    it "trunca valor_total em 0 quando o desconto é maior que o bruto" do
      orcamento = Orcamento.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        desconto: 500.0,
        orcamento_materiais_attributes: [
          { nome_material: "Cabo PP", valor: 50.0 }
        ]
      )

      expect(orcamento.valor_total.to_f).to eq(0.0)
    end

    it "recalcula totais ao destruir itens via nested attributes" do
      orcamento = Orcamento.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first,
        orcamento_servicos_attributes: [
          { equipamento_id: equipamento.id, valor_por_andar_id: valor_por_andar.id, quantidade: 1 }
        ],
        orcamento_materiais_attributes: [
          { nome_material: "Cabo PP", valor: 50.0 }
        ]
      )

      expect(orcamento.valor_total.to_f).to eq(400.0)

      orcamento.update!(
        orcamento_materiais_attributes: [
          { id: orcamento.orcamento_materiais.first.id, _destroy: true }
        ]
      )

      expect(orcamento.reload.subtotal_materiais.to_f).to eq(0.0)
      expect(orcamento.valor_total.to_f).to eq(350.0)
    end
  end

  describe "validações de pertencimento ao cliente" do
    it "rejeita endereço que pertence a outro cliente" do
      orcamento = Orcamento.new(
        cliente: cliente,
        endereco: outro_cliente.enderecos.first
      )

      expect(orcamento).not_to be_valid
      expect(orcamento.errors[:endereco_id]).to be_present
    end

    it "rejeita equipamento que pertence a outro cliente" do
      orcamento = Orcamento.create!(
        cliente: cliente,
        endereco: cliente.enderecos.first
      )

      vinculo = orcamento.orcamento_equipamentos.build(equipamento: equipamento_outro)
      expect(vinculo).not_to be_valid
      expect(vinculo.errors[:equipamento_id]).to be_present
    end
  end

  describe "scopes" do
    it "filtra por cliente, status e mês/ano" do
      orc1 = Orcamento.create!(cliente: cliente, endereco: cliente.enderecos.first, status: "enviado")
      orc2 = Orcamento.create!(cliente: outro_cliente, endereco: outro_cliente.enderecos.first, status: "aprovado")

      expect(Orcamento.por_cliente(cliente.id)).to contain_exactly(orc1)
      expect(Orcamento.por_status("aprovado")).to contain_exactly(orc2)
      expect(Orcamento.por_mes_e_ano(Time.current.month, Time.current.year)).to include(orc1, orc2)
    end
  end
end
