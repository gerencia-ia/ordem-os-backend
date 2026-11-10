class AddRolesInUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role_id, :bigint unless column_exists?(:users, :role_id)
    add_index :users, :role_id unless index_exists?(:users, :role_id)
    add_foreign_key :users, :roles, column: :role_id unless foreign_key_exists?(:users, :roles, column: :role_id)
  end
end
