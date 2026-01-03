class User < ApplicationRecord
  has_secure_password

  ROLES = { secretaria: 0, tecnico: 1 }.freeze
  ROLE_VALUES = ROLES.values.freeze

  before_validation :coerce_role

  validates :cpf, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLE_VALUES }

  def coerce_role
    if role.is_a?(String) || role.is_a?(Symbol)
      sym = role.to_sym rescue nil
      self.role = ROLES[sym] if sym && ROLES.key?(sym)
    end
    self.role ||= ROLE_VALUES.first
  end

  def role_name
    ROLES.key(role)&.to_s
  end
end
