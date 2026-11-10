# frozen_string_literal: true

class PrioridadePolicy < ApplicationPolicy
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
end
