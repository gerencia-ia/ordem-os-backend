# frozen_string_literal: true

class Cliente < ApplicationRecord
  normalizes :nome, with: ->(n) { n.to_s.strip }
  normalizes :email, with: ->(e) { e.to_s.strip.downcase }

  has_many :enderecos, dependent: :destroy, inverse_of: :cliente
  has_many :telefones, dependent: :destroy, inverse_of: :cliente
  has_many :equipamentos, dependent: :destroy, inverse_of: :cliente
  has_many :ordem_servicos, dependent: :restrict_with_error, inverse_of: :cliente

  accepts_nested_attributes_for :enderecos, allow_destroy: true
  accepts_nested_attributes_for :telefones, allow_destroy: true
  accepts_nested_attributes_for :equipamentos, allow_destroy: true

  before_validation :set_default_data_registro, on: :create

  validates :nome, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  validate :deve_ter_ao_menos_um_endereco, on: :create
  validate :deve_ter_ao_menos_um_telefone, on: :create

  private

  def set_default_data_registro
    self.data_registro ||= Time.current
  end

  def deve_ter_ao_menos_um_endereco
    if enderecos.reject(&:marked_for_destruction?).blank?
      errors.add(:enderecos, "deve conter ao menos um endereço")
    end
  end

  def deve_ter_ao_menos_um_telefone
    if telefones.reject(&:marked_for_destruction?).blank?
      errors.add(:telefones, "deve conter ao menos um telefone")
    end
  end
end
