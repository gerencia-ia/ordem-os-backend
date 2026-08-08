# frozen_string_literal: true

class OsEquipamento < ApplicationRecord
  belongs_to :ordem_servico, foreign_key: :ordem_servico_id, inverse_of: :os_equipamentos
  belongs_to :equipamento, foreign_key: :equipamento_id, inverse_of: :os_equipamentos

  validates :equipamento, :ordem_servico, presence: true
end
