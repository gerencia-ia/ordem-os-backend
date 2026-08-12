# frozen_string_literal: true

puts "Criando roles..."

[
  "Secretaria",
  "Técnico",
  "Administrador"
].each do |nome|
  Role.find_or_create_by!(nome: nome)
end

puts "✓ Roles: #{Role.count}"
