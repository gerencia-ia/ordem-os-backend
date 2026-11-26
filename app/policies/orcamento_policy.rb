# frozen_string_literal: true

class OrcamentoPolicy < ApplicationPolicy
  def index?
    admin_or_secretaria?
  end

  def show?
    admin_or_secretaria?
  end

  def create?
    admin_or_secretaria?
  end

  def update?
    admin_or_secretaria?
  end

  def destroy?
    admin_or_secretaria?
  end

  def update_status?
    admin_or_secretaria?
  end

  def converter_em_os?
    admin_or_secretaria?
  end

  private

  def admin_or_secretaria?
    user&.admin? || user&.secretaria?
  end
end
