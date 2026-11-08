# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.secretaria?
  end

  def show?
    user&.admin? || user&.secretaria? || record.id == user&.id
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin? || record.id == user&.id
  end

  def destroy?
    user&.admin? && record.id != user&.id
  end
end
