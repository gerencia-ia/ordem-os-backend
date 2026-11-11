# frozen_string_literal: true

class CreateAndares < ActiveRecord::Migration[8.0]
  def change
    create_table :andares do |t|
      t.string :descricao

      t.timestamps
    end
  end
end
