# frozen_string_literal: true

class CreateOrcamentos < ActiveRecord::Migration[8.0]
  def change
    create_table :orcamentos do |t|
      t.string :numero_orcamento, null: false
      t.references :cliente, null: false, foreign_key: true
      t.references :endereco, null: false, foreign_key: true
      t.references :ordem_servico,
                   null: true,
                   foreign_key: { on_delete: :nullify },
                   index: { unique: true, where: "ordem_servico_id IS NOT NULL" }
      t.string :status, null: false, default: "rascunho"
      t.date :data_validade
      t.decimal :subtotal_servicos, precision: 10, scale: 2, null: false, default: 0
      t.decimal :subtotal_materiais, precision: 10, scale: 2, null: false, default: 0
      t.decimal :desconto, precision: 10, scale: 2, null: false, default: 0
      t.decimal :valor_total, precision: 10, scale: 2, null: false, default: 0
      t.text :condicoes_pagamento
      t.text :observacao

      t.timestamps
    end

    add_index :orcamentos, :numero_orcamento, unique: true
    add_index :orcamentos, :status

    create_table :orcamento_equipamentos do |t|
      t.references :orcamento, null: false, foreign_key: true
      t.references :equipamento, null: false, foreign_key: true

      t.timestamps
    end

    add_index :orcamento_equipamentos, [ :orcamento_id, :equipamento_id ], unique: true

    create_table :orcamento_servicos do |t|
      t.references :orcamento, null: false, foreign_key: true
      t.references :equipamento, null: false, foreign_key: true
      t.references :valor_por_andar, null: false, foreign_key: { to_table: :valores_por_andares }
      t.integer :quantidade, null: false, default: 1
      t.string :nome_servico
      t.decimal :valor_unitario, precision: 10, scale: 2

      t.timestamps
    end

    add_index :orcamento_servicos,
              [ :orcamento_id, :equipamento_id, :valor_por_andar_id ],
              unique: true,
              name: "idx_orc_servicos_unique"

    create_table :orcamento_materiais do |t|
      t.references :orcamento, null: false, foreign_key: true
      t.references :material, null: true, foreign_key: { to_table: :materiais, on_delete: :nullify }
      t.string :nome_material, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
