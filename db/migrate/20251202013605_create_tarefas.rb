class CreateTarefas < ActiveRecord::Migration[8.0]
  def change
    create_table :tarefas do |t|
      t.references :ordem_servico, null: false, foreign_key: true
      t.string :descricao
      t.references :status, null: false, foreign_key: true
      t.bigint :user_id
      t.datetime :data_inicio
      t.datetime :data_fim
      t.timestamps
    end
  end
end
