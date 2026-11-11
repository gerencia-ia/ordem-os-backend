# frozen_string_literal: true

class CreateOsServicos < ActiveRecord::Migration[6.0]
  def change
    create_table :os_servicos do |t|
      t.references :servico
      t.references :ordem_servico
      t.integer :quantidade, default: 1
      t.timestamps
    end
  end
end
