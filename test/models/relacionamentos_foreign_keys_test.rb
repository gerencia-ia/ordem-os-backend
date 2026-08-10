# frozen_string_literal: true

require "test_helper"

class RelacionamentosForeignKeysTest < ActiveSupport::TestCase
  test "todas as colunas de relacionamento possuem foreign key no banco" do
    esperado = {
      "enderecos" => ["cliente_id"],
      "equipamentos" => ["cliente_id"],
      "ordem_servicos" => ["status_id", "prioridade_id", "cliente_id", "endereco_id"],
      "os_equipamentos" => ["equipamento_id", "ordem_servico_id"],
      "os_servicos" => ["servico_id", "ordem_servico_id"],
      "os_tecnicos" => ["ordem_servico_id", "tecnico_id"],
      "servicos" => ["categorias_servico_id"],
      "tarefas" => ["ordem_servico_id", "tecnico_id"],
      "telefones" => ["cliente_id"]
    }

    esperado.each do |table_name, colunas|
      colunas_atuais = ActiveRecord::Base.connection.foreign_keys(table_name).map(&:column)
      faltantes = colunas - colunas_atuais

      assert faltantes.empty?, "Faltam foreign keys em #{table_name}: #{faltantes.inspect}"
    end
  end
end
