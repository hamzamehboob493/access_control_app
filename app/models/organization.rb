class Organization < ApplicationRecord
  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :organization_type, inclusion: { in: %w[company nonprofit government educational] }

  # Scopes
  scope :verified, -> { where.not(verified_at: nil) }
  scope :by_type, ->(type) { where(organization_type: type) }

  def verified?
    verified_at.present?
  end

  def admin_users
    users.joins(:organization_memberships).where(organization_memberships: { role: "admin" })
  end

  def member_count
    organization_memberships.where(status: "active").count
  end

  def analytics_data
    {
      total_members: member_count,
      members_by_role: organization_memberships.group(:role).count,
      members_by_age_group: users.joins(:organization_memberships)
                                .where(organization_memberships: { status: "active" })
                                .group_by(&:age_group)
                                .transform_values(&:count)
    }
  end
end
