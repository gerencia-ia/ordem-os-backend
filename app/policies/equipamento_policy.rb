# frozen_string_literal: true

class EquipamentoPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user&.admin? || user&.secretaria?
  end

  def update?
    user&.admin? || user&.secretaria?
  end

  def destroy?
    user&.admin? || user&.secretaria?
  end

  def historico_laudos?
    user.present?
  end
end
