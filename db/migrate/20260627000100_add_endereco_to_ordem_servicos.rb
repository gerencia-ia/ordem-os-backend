# frozen_string_literal: true

class AddEnderecoToOrdemServicos < ActiveRecord::Migration[8.0]
  def change
    add_reference :ordem_servicos, :endereco, null: true, foreign_key: true
  end
end