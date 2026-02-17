# frozen_string_literal: true

class Servico < ApplicationRecord
  belongs_to :categorias_servico, optional: true
  
  validates :nome, :valor, presence: true
end
