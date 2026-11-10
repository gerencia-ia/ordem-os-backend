# frozen_string_literal: true

class OrdemServicoPolicy < ApplicationPolicy
  relation_scope do |relation|
    if user&.tecnico?
      relation.joins(:os_tecnicos).where(os_tecnicos: { user_id: user.id }).distinct
    else
      relation
    end
  end

  def index?
    user.present?
  end

  def show?
    admin_or_secretaria? || assigned_tecnico?
  end

  def create?
    admin_or_secretaria?
  end

  def update?
    admin_or_secretaria? || assigned_tecnico?
  end

  def destroy?
    admin_or_secretaria?
  end

  def update_status?
    admin_or_secretaria? || assigned_tecnico?
  end

  def update_laudo?
    admin_or_secretaria? || assigned_tecnico?
  end

  def add_servico?
    admin_or_secretaria?
  end

  def remove_servico?
    admin_or_secretaria?
  end

  def add_tecnico?
    admin_or_secretaria?
  end

  def remove_tecnico?
    admin_or_secretaria?
  end

  private

  def admin_or_secretaria?
    user&.admin? || user&.secretaria?
  end

  def assigned_tecnico?
    return false unless user&.tecnico?

    record.user_ids.include?(user.id)
  end
end
