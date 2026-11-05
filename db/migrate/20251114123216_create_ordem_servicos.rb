# frozen_string_literal: true

class CreateOrdemServicos < ActiveRecord::Migration[6.0]
  def change
    create_table :ordem_servicos do |t|
      t.references :status
      t.date :data_agendamento
      t.date :data_fechamento
      t.string :observacao
      t.references :prioridade
      t.decimal :valor_total
      t.timestamps
    end
  end
end
