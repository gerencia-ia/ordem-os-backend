class AddCpfToTecnicos < ActiveRecord::Migration[7.0]
  def change
    add_column :tecnicos, :cpf, :string, null: false, unique: true
    add_index :tecnicos, :cpf, unique: true
  end
end
