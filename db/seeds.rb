# frozen_string_literal: true

seed_users = [
  {
    cpf: '11111111111',
    password: '123456',
    role: :secretaria
  },
  {
    cpf: '22222222222',
    password: '123456',
    role: :tecnico,
    tecnico: {
      nome: 'Tecnico Demo',
      telefone: '11999999999',
      email: 'tecnico.demo@exemplo.com',
      especialidades: ['geral']
    }
  }
]

seed_users.each do |attrs|
  tecnico_attrs = attrs[:tecnico]

  ActiveRecord::Base.transaction do
    user = User.find_or_initialize_by(cpf: attrs[:cpf])
    user.password = attrs[:password]
    user.role = attrs[:role]
    user.save!

    next unless tecnico_attrs

    tecnico = Tecnico.find_or_initialize_by(cpf: attrs[:cpf])
    tecnico.assign_attributes(tecnico_attrs)
    tecnico.save!
  end
end

puts 'Seed de usuarios criado com sucesso.'