# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.secretaria?
  end

  def show?
    user&.admin? || user&.secretaria?
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end
end
