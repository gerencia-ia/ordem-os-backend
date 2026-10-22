# frozen_string_literal: true

class OsTecnico < ApplicationRecord
  belongs_to :ordem_servico, foreign_key: :ordem_servico_id, inverse_of: :os_tecnicos
  belongs_to :user, foreign_key: :user_id, inverse_of: :os_tecnicos

  validates :ordem_servico, :user, presence: true
end
