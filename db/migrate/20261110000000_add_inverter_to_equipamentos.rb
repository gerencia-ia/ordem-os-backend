# frozen_string_literal: true

class AddInverterToEquipamentos < ActiveRecord::Migration[8.0]
  def change
    add_column :equipamentos, :inverter, :boolean, default: false, null: false
  end
end
