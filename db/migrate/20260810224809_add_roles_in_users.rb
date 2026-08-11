class AddRolesInUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :role, :role_id

    add_foreign_key :users, :roles, column: :role_id
    add_index :users, :role_id
  end
end
