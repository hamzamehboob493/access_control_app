class OrganizationMembershipPolicy < ApplicationPolicy
  def show?
    user.present? && (user == record.user || user_can_view_members?)
  end

  def create?
    user.present? && user.age >= 13 # Minimum age to join organizations
  end

  def update?
    user.present? && (user == record.user || user_can_manage_members?)
  end

  def destroy?
    user.present? && (user == record.user || user_can_manage_members?)
  end

  def approve?
    user.present? && user_can_approve_members? && record.pending?
  end

  def reject?
    user.present? && user_can_approve_members? && record.pending?
  end

  def suspend?
    user.present? && user_can_suspend_members? && record.active?
  end

  def reactivate?
    user.present? && user_can_suspend_members? && record.status == "suspended"
  end

  def re_invite?
    user.present? && user_can_invite_members? && record.status == "pending"
  end

  def manage_permissions?
    user.present? && user_can_manage_roles?
  end

  private

  def user_membership
    @user_membership ||= user.organization_memberships.find_by(
      organization: record.organization,
      status: "active"
    )
  end

  def user_can_view_members?
    user_membership&.has_permission?("view_members") || user_membership&.admin?
  end

  def user_can_manage_members?
    user_membership&.can_manage_members?
  end

  def user_can_approve_members?
    user_membership&.can_approve_members?
  end

  def user_can_suspend_members?
    user_membership&.can_suspend_members?
  end

  def user_can_manage_roles?
    user_membership&.can_manage_roles?
  end

  def user_can_invite_members?
    user_membership&.has_permission?("invite_members") || user_membership&.admin?
  end

  class Scope < Scope
    def resolve
      if user.present?
        # Users can see their own memberships and memberships in organizations they can view
        viewable_org_ids = user.organization_memberships
                              .where(status: "active")
                              .joins(:permissions)
                              .where(permissions: { name: "view_members" })
                              .pluck(:organization_id)

        # Also include admin memberships (they can view all)
        admin_org_ids = user.organization_memberships
                           .where(status: "active", role: "admin")
                           .pluck(:organization_id)

        all_viewable_org_ids = (viewable_org_ids + admin_org_ids).uniq

        scope.where(
          "user_id = ? OR organization_id IN (?)",
          user.id,
          all_viewable_org_ids
        )
      else
        scope.none
      end
    end
  end
end
