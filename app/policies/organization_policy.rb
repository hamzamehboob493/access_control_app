class OrganizationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (record.verified? || user_is_member?)
  end

  def create?
    user.present? && user.age >= 18
  end

  def update?
    user.present? && user_is_admin?
  end

  def destroy?
    user.present? && user_is_admin?
  end

  def manage_members?
    user.present? && user_can_manage_members?
  end

  def view_analytics?
    user.present? && user_can_view_analytics?
  end

  private

  def user_is_member?
    user.organization_memberships.where(organization: record, status: "active").exists?
  end

  def user_is_admin?
    user.organization_memberships.where(organization: record, role: "admin", status: "active").exists?
  end

  def user_can_manage_members?
    membership = user.organization_memberships.find_by(organization: record, status: "active")
    membership&.can_manage_members?
  end

  def user_can_view_analytics?
    membership = user.organization_memberships.find_by(organization: record, status: "active")
    membership&.can_view_analytics?
  end
end
