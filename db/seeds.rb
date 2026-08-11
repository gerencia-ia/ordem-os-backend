# frozen_string_literal: true

puts "======================================"
puts "Iniciando seeds..."
puts "======================================"

load Rails.root.join("db/seeds/roles.rb")
load Rails.root.join("db/seeds/catalogo.rb")
load Rails.root.join("db/seeds/clientes.rb")
load Rails.root.join("db/seeds/tecnicos.rb")
load Rails.root.join("db/seeds/users.rb")
load Rails.root.join("db/seeds/ordens_servico.rb")

puts "======================================"
puts "Seeds executadas com sucesso!"
puts "======================================"
