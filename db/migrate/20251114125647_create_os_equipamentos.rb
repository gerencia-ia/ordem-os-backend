# frozen_string_literal: true

class CreateOsEquipamentos < ActiveRecord::Migration[6.0]
  def change
    create_table :os_equipamentos do |t|
      t.references :equipamento
      t.references :ordem_servico
      t.string :laudo
      t.timestamps
    end
  end
end
