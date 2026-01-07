# frozen_string_literal: true

class Equipamento < ApplicationRecord
  belongs_to :cliente

  validates :marca, :btus, :local_instalacao, presence: true
end
