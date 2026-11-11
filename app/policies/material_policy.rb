# frozen_string_literal: true

class MaterialPolicy < ApplicationPolicy
  def index? = user.present?
  def show? = user.present?
  def create? = user&.admin? || user&.secretaria?
  def update? = user&.admin? || user&.secretaria?
  def destroy? = user&.admin? || user&.secretaria?
end
