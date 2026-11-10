# frozen_string_literal: true

class CreateServicos < ActiveRecord::Migration[6.0]
  def change
    create_table :servicos do |t|
      t.string :nome
      t.decimal :valor
      t.timestamps
    end
  end
end
