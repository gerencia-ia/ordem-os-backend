# frozen_string_literal: true

puts "Criando clientes..."

clientes = [
  {
    nome: "Cliente Demo",
    email: "cliente.demo@example.com",
    data_ultima_visita: Date.current,

    endereco: {
      cidade: "Porto Velho",
      rua: "Rua Principal",
      numero: "100",
      bairro: "Centro",
      complemento: "Casa",
      cep: "76801-000"
    },

    telefone: "69999999999",

    equipamento: {
      marca: "Samsung",
      observacao: "Equipamento funcionando, necessita limpeza.",
      local_instalacao: "Sala",
      btus: "12000"
    }
  },

  {
    nome: "Empresa Exemplo LTDA",
    email: "empresa@example.com",

    endereco: {
      cidade: "Porto Velho",
      rua: "Avenida Brasil",
      numero: "500",
      bairro: "Industrial",
      complemento: nil,
      cep: "76800-000"
    },

    telefone: "69333333333",

    equipamento: {
      marca: "LG",
      observacao: "Apresentando falha no resfriamento.",
      local_instalacao: "Recepção",
      btus: "18000"
    }
  }
]

clientes.each do |attrs|
  ActiveRecord::Base.transaction do
    cliente = Cliente.find_or_initialize_by(
      email: attrs[:email]
    )

    cliente.nome = attrs[:nome]
    cliente.data_registro ||= Time.current
    cliente.data_ultima_visita ||= attrs[:data_ultima_visita]

    if cliente.new_record?
      cliente.enderecos.build(attrs[:endereco])
      cliente.telefones.build(numero: attrs[:telefone])

      cliente.save!
    end

    # ----------------------------------------------------------
    # ENDEREÇO
    # ----------------------------------------------------------

    endereco = cliente.enderecos.find_or_create_by!(
      rua: attrs[:endereco][:rua],
      numero: attrs[:endereco][:numero]
    ) do |record|
      record.cidade = attrs[:endereco][:cidade]
      record.bairro = attrs[:endereco][:bairro]
      record.complemento = attrs[:endereco][:complemento]
      record.cep = attrs[:endereco][:cep]
    end

    # ----------------------------------------------------------
    # TELEFONE
    # ----------------------------------------------------------

    cliente.telefones.find_or_create_by!(
      numero: attrs[:telefone]
    )

    # ----------------------------------------------------------
    # EQUIPAMENTO
    # ----------------------------------------------------------

    equipamento_attrs = attrs[:equipamento]

    Equipamento.find_or_create_by!(
      cliente: cliente,
      marca: equipamento_attrs[:marca]
    ) do |equipamento|
      equipamento.observacao = equipamento_attrs[:observacao]
      equipamento.local_instalacao = equipamento_attrs[:local_instalacao]
      equipamento.btus = equipamento_attrs[:btus]
    end
  end
end

puts "✓ Clientes: #{Cliente.count}"
puts "✓ Endereços: #{Endereco.count}"
puts "✓ Telefones: #{Telefone.count}"
puts "✓ Equipamentos: #{Equipamento.count}"
