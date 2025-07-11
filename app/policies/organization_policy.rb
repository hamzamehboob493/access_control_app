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
    user.present? && user_can_edit_organization?
  end

  def destroy?
    user.present? && user_can_delete_organization?
  end

  def manage_members?
    user.present? && user_can_manage_members?
  end

  def invite_members?
    user.present? && user_can_invite_members?
  end

  def view_analytics?
    user.present? && user_can_view_analytics?
  end

  def export_analytics?
    user.present? && user_can_export_analytics?
  end

  def manage_roles?
    user.present? && user_can_manage_roles?
  end

  def moderate_content?
    user.present? && user_can_moderate_content?
  end

  private

  def user_is_member?
    user.organization_memberships.where(organization: record, status: "active").exists?
  end

  def user_membership
    @user_membership ||= user.organization_memberships.find_by(organization: record, status: "active")
  end

  def user_can_manage_members?
    user_membership&.can_manage_members?
  end

  def user_can_invite_members?
    user_membership&.can_invite_members?
  end

  def user_can_view_analytics?
    user_membership&.can_view_analytics?
  end

  def user_can_export_analytics?
    user_membership&.has_permission?("export_analytics")
  end

  def user_can_edit_organization?
    user_membership&.can_edit_organization?
  end

  def user_can_delete_organization?
    user_membership&.has_permission?("delete_organization")
  end

  def user_can_manage_roles?
    user_membership&.can_manage_roles?
  end

  def user_can_moderate_content?
    user_membership&.can_moderate_content?
  end
end
