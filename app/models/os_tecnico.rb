# frozen_string_literal: true

class OsTecnico < ApplicationRecord
  belongs_to :ordem_servico, inverse_of: :os_tecnicos
  belongs_to :user, inverse_of: :os_tecnicos

  validates :ordem_servico, :user, presence: true
  validates :user_id, uniqueness: { scope: :ordem_servico_id, message: "já está atribuído a esta ordem de serviço" }
end
