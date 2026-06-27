# frozen_string_literal: true

class AddCepToEnderecos < ActiveRecord::Migration[8.0]
  def change
    add_column :enderecos, :cep, :string
  end
end