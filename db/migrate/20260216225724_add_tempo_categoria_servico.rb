class AddTempoCategoriaServico < ActiveRecord::Migration[8.0]
  def change
    # CORREÇÃO: Nome da tabela no plural (:categorias_servicos)
    create_table :categorias_servicos do |t|
      t.string :descricao, null: false
      t.timestamps
    end

    add_column :servicos, :tempo_servico, :integer
    
    # O Rails vai procurar a tabela 'categorias_servicos' automaticamente
    # e criar a coluna 'categorias_servico_id'
    add_reference :servicos, :categorias_servico, foreign_key: true
  end
end