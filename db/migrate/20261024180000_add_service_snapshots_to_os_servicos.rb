# frozen_string_literal: true

class AddServiceSnapshotsToOsServicos < ActiveRecord::Migration[8.0]
  def up
    add_column :os_servicos, :nome_servico, :string
    add_column :os_servicos, :valor_unitario, :decimal, precision: 10, scale: 2

    execute <<~SQL
      UPDATE os_servicos
      SET nome_servico = servicos.nome,
          valor_unitario = servicos.valor
      FROM servicos
      WHERE os_servicos.servico_id = servicos.id
    SQL
  end

  def down
    remove_column :os_servicos, :valor_unitario
    remove_column :os_servicos, :nome_servico
  end
end
