# frozen_string_literal: true

class CreateAddColumnEquipamentos < ActiveRecord::Migration[6.0]
  def change
    add_column :equipamentos, :local_instalacao, :string
    remove_column :equipamentos, :numero_serie, :string
  end
end
