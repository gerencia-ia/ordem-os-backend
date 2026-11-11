# frozen_string_literal: true

class AlterOsServicos < ActiveRecord::Migration[8.0]
  def change
    change_table :os_servicos do |t|
      t.references :valor_por_andar, null: false, foreign_key: true
      t.references :equipamento, null: false, foreign_key: true
      t.remove :servico_id
    end
  end
end
