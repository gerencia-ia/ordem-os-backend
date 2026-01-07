class AddAtendimentoTimestampsToOrdemServicos < ActiveRecord::Migration[8.0]
  def change
    add_column :ordem_servicos, :data_inicio_atendimento, :datetime
    add_column :ordem_servicos, :data_fim_atendimento, :datetime
  end
end
