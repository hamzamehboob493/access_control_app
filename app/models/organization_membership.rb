class OrganizationMembership < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :organization
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :invited_by, class_name: "User", optional: true
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  # Validations
  validates :user_id, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :role, inclusion: { in: %w[admin manager member viewer] }
  validates :status, inclusion: { in: %w[pending active suspended inactive rejected] }
  validates :verification_method, inclusion: { in: %w[email phone invitation direct_approval] }, allow_blank: true
  validates :invitation_token, uniqueness: true, allow_blank: true
  validates :invited_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :invitation_based?
  validate :user_or_invitation_token_present
  validate :no_duplicate_invitation_for_organization

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :pending, -> { where(status: "pending") }
  scope :by_role, ->(role) { where(role: role) }
  scope :awaiting_approval, -> { where(status: "pending", requested_at: nil) }
  scope :requested, -> { where(status: "pending").where.not(requested_at: nil) }

  # Callbacks
  before_create :set_requested_at, if: :pending?
  before_create :generate_invitation_token, if: :invitation_based?
  after_create :sync_role_permissions, if: :user_id?
  after_update :sync_role_permissions, if: :saved_change_to_role?

  # Methods
  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def can_manage_members?
    has_permission?("manage_members") || admin?
  end

  def can_view_analytics?
    has_permission?("view_analytics") || admin?
  end

  def can_invite_members?
    has_permission?("invite_members") || admin?
  end

  def can_approve_members?
    has_permission?("approve_members") || admin?
  end

  def can_suspend_members?
    has_permission?("suspend_members") || admin?
  end

  def can_edit_organization?
    has_permission?("edit_organization") || admin?
  end

  def can_manage_roles?
    has_permission?("manage_roles") || admin?
  end

  def can_moderate_content?
    has_permission?("moderate_content") || admin?
  end

  def has_permission?(permission_name)
    return true if admin? && active?
    return false unless active?
    return false unless user_id.present?

    permissions.exists?(name: permission_name)
  end

  def has_any_permission?(*permission_names)
    return true if admin? && active?
    return false unless active?
    return false unless user_id.present?

    permissions.where(name: permission_names).exists?
  end

  def permission_names
    return [] unless user_id.present?
    permissions.pluck(:name)
  end

  def permissions_by_category
    return {} unless user_id.present?
    permissions.group_by(&:category)
  end

  def pending?
    status == "pending"
  end

  def active?
    status == "active"
  end

  def approved?
    approved_at.present?
  end

  def invitation_based?
    verification_method == "invitation"
  end

  def approve!(approver, notes = nil)
    update!(
      status: "active",
      approved_at: Time.current,
      approved_by: approver,
      joined_at: Time.current,
      verification_notes: notes
    )
  end

  def reject!(approver, notes = nil)
    update!(
      status: "rejected",
      approved_by: approver,
      verification_notes: notes
    )
  end

  def suspend!(approver, notes = nil)
    update!(
      status: "suspended",
      verification_notes: notes
    )
  end

  def reactivate!(approver, notes = nil)
    update!(
      status: "active",
      verification_notes: notes
    )
  end

  def grant_permission(permission)
    return unless user_id.present?
    RolePermission.grant_permission(self, permission)
  end

  def revoke_permission(permission)
    return unless user_id.present?
    RolePermission.revoke_permission(self, permission)
  end

  def sync_role_permissions
    return unless user_id.present?
    RolePermission.sync_role_permissions(self)
  end

  private

  def set_requested_at
    self.requested_at = Time.current if requested_at.blank?
  end

  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64(32)
  end

  def user_or_invitation_token_present
    if user_id.blank? && invitation_token.blank?
      errors.add(:base, "Must have either a user or an invitation token")
    end
  end

  def no_duplicate_invitation_for_organization
    return unless organization_id.present?

    # Check for existing active membership if user is present
    if user_id.present?
      existing = OrganizationMembership.where(
        user_id: user_id,
        organization_id: organization_id,
        status: %w[active pending]
      ).where.not(id: id)

      if existing.exists?
        errors.add(:base, "User already has an active or pending membership in this organization")
      end
    end
  end
end
