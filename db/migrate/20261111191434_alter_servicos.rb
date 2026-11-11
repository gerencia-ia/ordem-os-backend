# frozen_string_literal: true

class AlterServicos < ActiveRecord::Migration[8.0]
  def change
    change_table :servicos do |t|
      t.remove :valor
    end
  end
end
