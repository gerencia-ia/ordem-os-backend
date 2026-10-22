# frozen_string_literal: true

puts "Criando catálogo..."

# ============================================================
# STATUS
# ============================================================

[
  "Aberta",
  "Não iniciada",
  "Em andamento",
  "Aguardando",
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
  Prioridade.find_or_create_by!(descricao: descricao)
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
# SERVIÇOS
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
    valor: 350.00,
    tempo_servico: 180,
    categoria: categorias[:instalacao]
  },
  {
    nome: "Manutenção preventiva",
    valor: 180.00,
    tempo_servico: 120,
    categoria: categorias[:manutencao]
  },
  {
    nome: "Limpeza de ar-condicionado",
    valor: 120.00,
    tempo_servico: 90,
    categoria: categorias[:limpeza]
  },
  {
    nome: "Reparo de ar-condicionado",
    valor: 250.00,
    tempo_servico: 180,
    categoria: categorias[:reparo]
  }
]

servicos.each do |attrs|
  servico = Servico.find_or_initialize_by(nome: attrs[:nome])

  servico.valor = attrs[:valor]
  servico.tempo_servico = attrs[:tempo_servico]
  servico.categorias_servico = attrs[:categoria]

  servico.save!
end

puts "✓ Status: #{Status.count}"
puts "✓ Prioridades: #{Prioridade.count}"
puts "✓ Categorias: #{CategoriasServico.count}"
puts "✓ Serviços: #{Servico.count}"
