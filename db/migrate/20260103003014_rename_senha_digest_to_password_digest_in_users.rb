class RenameSenhaDigestToPasswordDigestInUsers < ActiveRecord::Migration[8.0]
  def change
        rename_column :users, :senha_digest, :password_digest
  end
end
