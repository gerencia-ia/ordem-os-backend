# frozen_string_literal: true

class CreateMateriaisAndOsMateriais < ActiveRecord::Migration[8.0]
  def change
    create_table :materiais do |t|
      t.string :nome, null: false
      t.text :descricao
      t.decimal :valor_referencia, precision: 10, scale: 2
      t.timestamps
    end

    create_table :os_materiais do |t|
      t.references :ordem_servico, null: false, foreign_key: true
      t.references :material, null: true, foreign_key: { to_table: :materiais, on_delete: :nullify }
      t.string :nome_material, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
