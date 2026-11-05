# frozen_string_literal: true

class CreateEnderecos < ActiveRecord::Migration[6.0]
  def change
    create_table :enderecos do |t|
      t.string :logradouro
      t.string :cep
      t.string :cidade
      t.string :estado
      t.references :cliente
      t.timestamps
    end
  end
end
