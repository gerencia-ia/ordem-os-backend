# frozen_string_literal: true

puts "Criando usuários..."

roles = {
  secretaria: Role.find_by!(nome: "Secretaria"),
  tecnico: Role.find_by!(nome: "Técnico"),
  administrador: Role.find_by!(nome: "Administrador")
}

users = [
  {
    cpf: "11111111111",
    password: "123456",
    role: roles[:secretaria]
  },
  {
    cpf: "22222222222",
    password: "123456",
    role: roles[:tecnico]
  },
  {
    cpf: "99999999999",
    password: "123456",
    role: roles[:administrador]
  }
]

users.each do |attrs|
  user = User.find_or_initialize_by(cpf: attrs[:cpf])

  user.password = attrs[:password]
  user.role = attrs[:role]

  user.save!
end

puts "✓ Usuários: #{User.count}"
