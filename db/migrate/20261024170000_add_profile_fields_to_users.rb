class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :nome, :string unless column_exists?(:users, :nome)
    add_column :users, :email, :string unless column_exists?(:users, :email)
    add_column :users, :telefone, :string unless column_exists?(:users, :telefone)
  end
end
