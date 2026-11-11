# frozen_string_literal: true

class CreateValoresPorAndares < ActiveRecord::Migration[8.0]
  def change
    create_table :valores_por_andares do |t|
      t.references :servico, null: false, foreign_key: true
      t.references :andar, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2

      t.timestamps
    end
  end
end
