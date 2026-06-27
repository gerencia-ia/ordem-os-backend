# frozen_string_literal: true

class AddDataUltimaVisitaToClientes < ActiveRecord::Migration[7.2]
  def change
    add_column :clientes, :data_ultima_visita, :date
  end
end
