class RolePermission < ApplicationRecord
  # Associations
  belongs_to :organization_membership
  belongs_to :permission

  # Validations
  validates :organization_membership_id, uniqueness: { scope: :permission_id }

  # Scopes
  scope :for_membership, ->(membership) { where(organization_membership: membership) }
  scope :for_permission, ->(permission) { where(permission: permission) }

  # Class methods
  def self.grant_permission(membership, permission)
    find_or_create_by(organization_membership: membership, permission: permission)
  end

  def self.revoke_permission(membership, permission)
    find_by(organization_membership: membership, permission: permission)&.destroy
  end

  def self.sync_role_permissions(membership)
    # Remove existing permissions
    where(organization_membership: membership).destroy_all

    # Add permissions for the current role
    Permission.for_role(membership.role).each do |permission|
      grant_permission(membership, permission)
    end
  end
end
