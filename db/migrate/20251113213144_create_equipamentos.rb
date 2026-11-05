# frozen_string_literal: true

class CreateEquipamentos < ActiveRecord::Migration[6.0]
  def change
    create_table :equipamentos do |t|
      t.string :marca
      t.string :modelo
      t.string :num_serie
      t.integer :capacidade
      t.string :observacao
      t.references :cliente
      t.timestamps
    end
  end
end
