# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_27_000100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categorias_servicos", force: :cascade do |t|
    t.string "descricao", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clientes", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.datetime "data_registro"
    t.date "data_ultima_visita"
  end

  create_table "enderecos", force: :cascade do |t|
    t.string "cidade"
    t.bigint "cliente_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rua"
    t.string "numero"
    t.string "bairro"
    t.string "complemento"
    t.string "cep"
    t.index ["cliente_id"], name: "index_enderecos_on_cliente_id"
  end

  create_table "equipamentos", force: :cascade do |t|
    t.string "marca"
    t.string "observacao"
    t.bigint "cliente_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "local_instalacao"
    t.string "btus"
    t.index ["cliente_id"], name: "index_equipamentos_on_cliente_id"
  end

  create_table "ordem_servicos", force: :cascade do |t|
    t.bigint "status_id"
    t.datetime "data_agendamento"
    t.date "data_fechamento"
    t.string "observacao"
    t.bigint "prioridade_id"
    t.decimal "valor_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "numero_ordem"
    t.string "descricao"
    t.string "tipo_servico"
    t.date "data_vencimento"
    t.decimal "custo_estimado", precision: 10, scale: 2
    t.bigint "cliente_id"
    t.datetime "data_inicio_atendimento"
    t.datetime "data_fim_atendimento"
    t.bigint "endereco_id"
    t.index ["cliente_id"], name: "index_ordem_servicos_on_cliente_id"
    t.index ["endereco_id"], name: "index_ordem_servicos_on_endereco_id"
    t.index ["prioridade_id"], name: "index_ordem_servicos_on_prioridade_id"
    t.index ["status_id"], name: "index_ordem_servicos_on_status_id"
  end

  create_table "os_equipamentos", force: :cascade do |t|
    t.bigint "equipamento_id"
    t.bigint "ordem_servico_id"
    t.string "laudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipamento_id"], name: "index_os_equipamentos_on_equipamento_id"
    t.index ["ordem_servico_id"], name: "index_os_equipamentos_on_ordem_servico_id"
  end

  create_table "os_servicos", force: :cascade do |t|
    t.bigint "servico_id"
    t.bigint "ordem_servico_id"
    t.decimal "quantidade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ordem_servico_id"], name: "index_os_servicos_on_ordem_servico_id"
    t.index ["servico_id"], name: "index_os_servicos_on_servico_id"
  end

  create_table "os_tecnicos", force: :cascade do |t|
    t.bigint "ordem_servico_id"
    t.bigint "tecnico_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ordem_servico_id"], name: "index_os_tecnicos_on_ordem_servico_id"
    t.index ["tecnico_id"], name: "index_os_tecnicos_on_tecnico_id"
  end

  create_table "prioridades", force: :cascade do |t|
    t.string "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servicos", force: :cascade do |t|
    t.string "nome"
    t.decimal "valor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tempo_servico"
    t.bigint "categorias_servico_id"
    t.index ["categorias_servico_id"], name: "index_servicos_on_categorias_servico_id"
  end

  create_table "status", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tarefas", force: :cascade do |t|
    t.bigint "ordem_servico_id", null: false
    t.string "descricao"
    t.string "status", default: "nao_iniciada"
    t.bigint "tecnico_id"
    t.datetime "data_inicio"
    t.datetime "data_fim"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ordem_servico_id"], name: "index_tarefas_on_ordem_servico_id"
    t.index ["tecnico_id"], name: "index_tarefas_on_tecnico_id"
  end

  create_table "tecnicos", force: :cascade do |t|
    t.string "nome"
    t.string "telefone"
    t.string "especialidades", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "status_disponibilidade", default: "disponivel"
    t.string "cpf", null: false
    t.index ["cpf"], name: "index_tecnicos_on_cpf", unique: true
  end

  create_table "telefones", force: :cascade do |t|
    t.string "numero"
    t.bigint "cliente_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_telefones_on_cliente_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "cpf", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["cpf"], name: "index_users_on_cpf", unique: true
  end

  add_foreign_key "ordem_servicos", "clientes"
  add_foreign_key "ordem_servicos", "enderecos"
  add_foreign_key "servicos", "categorias_servicos"
  add_foreign_key "tarefas", "ordem_servicos"
  add_foreign_key "tarefas", "tecnicos"
end
