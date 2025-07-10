class OrganizationMembership < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :organization

  # Validations
  validates :user_id, uniqueness: { scope: :organization_id }
  validates :role, inclusion: { in: %w[admin manager member viewer] }
  validates :status, inclusion: { in: %w[pending active suspended inactive] }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :by_role, ->(role) { where(role: role) }

  # Methods
  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def can_manage_members?
    admin? || manager?
  end

  def can_view_analytics?
    admin? || manager?
  end
end
