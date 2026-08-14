class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :nome
      t.string :cpf, null: false
      t.string :email
      t.string :telefone
      t.bigint :role_id
      t.string :senha_digest, null: false

      t.timestamps
    end

    add_index :users, :cpf, unique: true
  end
end