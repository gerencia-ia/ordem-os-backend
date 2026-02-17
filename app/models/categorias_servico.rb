# frozen_string_literal: true

class CategoriasServico < ApplicationRecord
  has_many :servicos
  
  validates :descricao, presence: true, uniqueness: true
end
