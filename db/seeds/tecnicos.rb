# frozen_string_literal: true

puts "Criando técnicos..."

tecnicos = [
  {
    cpf: "33333333333",
    nome: "Técnico Demo",
    telefone: "11999999999",
    email: "tecnico.demo@example.com",
    especialidades: [ "geral", "manutenção" ],
    status_disponibilidade: "disponivel"
  },
  {
    cpf: "44444444444",
    nome: "João Técnico",
    telefone: "11888888888",
    email: "joao.tecnico@example.com",
    especialidades: [ "instalação", "reparo" ],
    status_disponibilidade: "disponivel"
  }
]

tecnicos.each do |attrs|
  tecnico = Tecnico.find_or_initialize_by(cpf: attrs[:cpf])

  tecnico.assign_attributes(
    nome: attrs[:nome],
    telefone: attrs[:telefone],
    email: attrs[:email],
    especialidades: attrs[:especialidades],
    status_disponibilidade: attrs[:status_disponibilidade]
  )

  tecnico.save!
end

puts "✓ Técnicos: #{Tecnico.count}"
