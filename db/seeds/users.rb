# frozen_string_literal: true

puts "Criando usuários..."

roles = {
  secretaria: Role.find_by!(nome: "Secretaria"),
  tecnico: Role.find_by!(nome: "Técnico"),
  administrador: Role.find_by!(nome: "Administrador")
}

users = [
  {
    nome: "Sophia Marlene",
    cpf: "11111111111",
    email: "sophia@example.com",
    telefone: "73993564830",
    password: "123456",
    role: roles[:secretaria]
  },
  {
    nome: "Gabriel Renan",
    cpf: "22222222222",
    email: "gabriel@example.com",
    telefone: "73926141694",
    password: "123456",
    role: roles[:tecnico]
  },
  {
    nome: "Letícia Andreia",
    cpf: "33333333333",
    email: "leticia@example.com",
    telefone: "11997499375",
    password: "123456",
    role: roles[:administrador]
  },
  {
    nome: "Cauã Vicente",
    cpf: "44444444444",
    email: "caua@example.com",
    telefone: "11999999999",
    password: "123456",
    role: roles[:tecnico]
  },
  {
    nome: "Jaqueline Aurora",
    cpf: "55555555555",
    email: "jaqueline@example.com",
    telefone: "11888888888",
    password: "123456",
    role: roles[:tecnico]

  }
]

users.each do |attrs|
  user = User.find_or_initialize_by(cpf: attrs[:cpf])
  user.nome = attrs[:nome]
  user.telefone = attrs[:telefone]
  user.email = attrs[:email]
  user.role = attrs[:role]
  user.password = attrs[:password]

  user.save!
end

puts "✓ Usuários: #{User.count}"
