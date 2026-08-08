# frozen_string_literal: true

class Cliente < ApplicationRecord
  validates :nome, presence: true
  has_many :enderecos, foreign_key: :cliente_id, dependent: :destroy, inverse_of: :cliente
  has_many :telefones, foreign_key: :cliente_id, dependent: :destroy, inverse_of: :cliente
  has_many :equipamentos, foreign_key: :cliente_id, dependent: :destroy, inverse_of: :cliente
  has_many :ordem_servicos, foreign_key: :cliente_id, dependent: :restrict_with_error, inverse_of: :cliente

  accepts_nested_attributes_for :enderecos, allow_destroy: true
  accepts_nested_attributes_for :telefones, allow_destroy: true
  accepts_nested_attributes_for :equipamentos, allow_destroy: true

  validate :deve_ter_ao_menos_um_endereco, on: :create
  validate :deve_ter_ao_menos_um_telefone, on: :create

  private

  def deve_ter_ao_menos_um_endereco
    if enderecos.reject(&:marked_for_destruction?).blank?
      errors.add(:enderecos, 'deve conter ao menos um endereço')
    end
  end

  def deve_ter_ao_menos_um_telefone
    if telephones_collection_blank?
      errors.add(:telefones, 'deve conter ao menos um telefone')
    end
  end

  def telephones_collection_blank?
    assoc = respond_to?(:telefones) ? telefones : []
    assoc.reject(&:marked_for_destruction?).blank?
  end
end
