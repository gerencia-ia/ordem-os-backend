# frozen_string_literal: true

class AlterEquipamento < ActiveRecord::Migration[8.0]
  def change
    change_table :equipamentos do |t|
      t.references :andar, null: false, foreign_key: true
    end
  end
end
