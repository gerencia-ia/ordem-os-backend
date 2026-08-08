# frozen_string_literal: true

class OsServico < ApplicationRecord
  belongs_to :ordem_servico, foreign_key: :ordem_servico_id, inverse_of: :os_servicos
  belongs_to :servico, foreign_key: :servico_id, inverse_of: :os_servicos

  validates :servico, :ordem_servico, presence: true
end
