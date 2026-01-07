class ChangeDataAgendamentoToDatetime < ActiveRecord::Migration[8.0]
  def up
    change_column :ordem_servicos, :data_agendamento, :datetime
  end

  def down
    change_column :ordem_servicos, :data_agendamento, :date
  end
end
