# frozen_string_literal: true

class AddMissingForeignKeys < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :enderecos, :clientes, if_not_exists: true
    add_foreign_key :equipamentos, :clientes, if_not_exists: true

    add_foreign_key :ordem_servicos, :status, if_not_exists: true
    add_foreign_key :ordem_servicos, :prioridades, if_not_exists: true
    add_foreign_key :ordem_servicos, :clientes, if_not_exists: true
    add_foreign_key :ordem_servicos, :enderecos, if_not_exists: true

    add_foreign_key :os_equipamentos, :equipamentos, if_not_exists: true
    add_foreign_key :os_equipamentos, :ordem_servicos, if_not_exists: true

    add_foreign_key :os_servicos, :servicos, if_not_exists: true
    add_foreign_key :os_servicos, :ordem_servicos, if_not_exists: true

    add_foreign_key :os_tecnicos, :ordem_servicos, if_not_exists: true
    add_foreign_key :os_tecnicos, :tecnicos, if_not_exists: true

    add_foreign_key :servicos, :categorias_servicos, if_not_exists: true

    add_foreign_key :tarefas, :ordem_servicos, if_not_exists: true
    add_foreign_key :tarefas, :tecnicos, if_not_exists: true

    add_foreign_key :telefones, :clientes, if_not_exists: true
  end
end
