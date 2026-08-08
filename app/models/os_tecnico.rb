# frozen_string_literal: true

class OsTecnico < ApplicationRecord
  belongs_to :ordem_servico, foreign_key: :ordem_servico_id, inverse_of: :os_tecnicos
  belongs_to :tecnico, foreign_key: :tecnico_id, inverse_of: :os_tecnicos

  validates :ordem_servico, :tecnico, presence: true
end
