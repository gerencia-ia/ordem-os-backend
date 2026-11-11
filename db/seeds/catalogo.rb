# frozen_string_literal: true

puts "Criando catálogo..."

# ============================================================
# STATUS
# ============================================================

[
  "Não iniciada",
  "Em andamento",
  "Concluída",
  "Cancelada"
].each do |nome|
  Status.find_or_create_by!(nome: nome)
end

# ============================================================
# PRIORIDADES
# ============================================================

[
  "Baixa",
  "Média",
  "Alta",
  "Urgente"
].each do |descricao|
  prioridade = Prioridade.where("LOWER(descricao) = ?", descricao.downcase).first_or_initialize
  prioridade.descricao = descricao
  prioridade.save!
end

# ============================================================
# CATEGORIAS DE SERVIÇOS
# ============================================================

[
  "Instalação",
  "Manutenção",
  "Limpeza",
  "Reparo"
].each do |descricao|
  CategoriasServico.find_or_create_by!(descricao: descricao)
end

# ============================================================
# ANDARES
# ============================================================

andares_config = [
  { descricao: "Térreo", acrescimo: 0.00 },
  { descricao: "1º Andar", acrescimo: 30.00 },
  { descricao: "2º Andar", acrescimo: 60.00 },
  { descricao: "3º Andar", acrescimo: 90.00 }
]

andares = andares_config.map do |attrs|
  andar = Andar.where("LOWER(descricao) = ?", attrs[:descricao].downcase).first_or_initialize
  andar.descricao = attrs[:descricao]
  andar.save!

  { record: andar, acrescimo: attrs[:acrescimo] }
end

# ============================================================
# SERVIÇOS E VALORES POR ANDAR
# ============================================================

categorias = {
  instalacao: CategoriasServico.find_by!(descricao: "Instalação"),
  manutencao: CategoriasServico.find_by!(descricao: "Manutenção"),
  limpeza: CategoriasServico.find_by!(descricao: "Limpeza"),
  reparo: CategoriasServico.find_by!(descricao: "Reparo")
}

servicos = [
  {
    nome: "Instalação de ar-condicionado",
    valor_base: 350.00,
    tempo_servico: 180,
    categoria: categorias[:instalacao]
  },
  {
    nome: "Manutenção preventiva",
    valor_base: 180.00,
    tempo_servico: 120,
    categoria: categorias[:manutencao]
  },
  {
    nome: "Limpeza de ar-condicionado",
    valor_base: 120.00,
    tempo_servico: 90,
    categoria: categorias[:limpeza]
  },
  {
    nome: "Reparo de ar-condicionado",
    valor_base: 250.00,
    tempo_servico: 180,
    categoria: categorias[:reparo]
  }
]

servicos.each do |attrs|
  servico = Servico.where("LOWER(nome) = ?", attrs[:nome].downcase).first_or_initialize

  servico.nome = attrs[:nome]
  servico.tempo_servico = attrs[:tempo_servico]
  servico.categorias_servico = attrs[:categoria]

  servico.save!

  andares.each do |andar_info|
    valor_por_andar = ValorPorAndar.find_or_initialize_by(
      servico: servico,
      andar: andar_info[:record]
    )

    valor_por_andar.valor = attrs[:valor_base] + andar_info[:acrescimo]
    valor_por_andar.save!
  end
end

puts "✓ Status: #{Status.count}"
puts "✓ Prioridades: #{Prioridade.count}"
puts "✓ Categorias: #{CategoriasServico.count}"
puts "✓ Andares: #{Andar.count}"
puts "✓ Serviços: #{Servico.count}"
puts "✓ Valores por andar: #{ValorPorAndar.count}"
