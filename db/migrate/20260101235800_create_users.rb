class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :cpf, null: false, unique: true
      t.string :senha_digest, null: false
      t.string :role, null: false

      t.timestamps
    end
    add_index :users, :cpf, unique: true
  end
end