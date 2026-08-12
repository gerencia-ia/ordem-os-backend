# frozen_string_literal: true

class CreateTelefones < ActiveRecord::Migration[6.0]
  def change
    create_table :telefones do |t|
      t.string :numero
      t.references :cliente
      t.timestamps
    end
  end
end
