class Permission < ApplicationRecord
  # Associations
  has_many :role_permissions, dependent: :destroy
  has_many :organization_memberships, through: :role_permissions

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validates :category, inclusion: { in: %w[membership content analytics administration moderation] }

  # Scopes
  scope :by_category, ->(category) { where(category: category) }

  # Constants for common permissions
  PERMISSIONS = {
    membership: {
      "view_members" => "View organization members",
      "manage_members" => "Manage organization memberships",
      "invite_members" => "Invite new members",
      "approve_members" => "Approve membership requests",
      "suspend_members" => "Suspend or ban members"
    },
    content: {
      "view_content" => "View organization content",
      "create_content" => "Create new content",
      "edit_content" => "Edit existing content",
      "delete_content" => "Delete content",
      "moderate_content" => "Moderate user-generated content"
    },
    analytics: {
      "view_analytics" => "View organization analytics",
      "export_analytics" => "Export analytics data",
      "view_member_analytics" => "View detailed member analytics"
    },
    administration: {
      "edit_organization" => "Edit organization settings",
      "manage_roles" => "Manage roles and permissions",
      "delete_organization" => "Delete the organization",
      "manage_settings" => "Manage organization configuration"
    },
    moderation: {
      "moderate_discussions" => "Moderate discussions and comments",
      "issue_warnings" => "Issue warnings to members",
      "handle_reports" => "Handle user reports and complaints"
    }
  }.freeze

  # Class methods
  def self.seed_permissions!
    PERMISSIONS.each do |category, perms|
      perms.each do |name, description|
        find_or_create_by(name: name) do |permission|
          permission.description = description
          permission.category = category.to_s
        end
      end
    end
  end

  def self.for_role(role)
    case role.to_s
    when "admin"
      all
    when "manager"
      where(category: %w[membership content analytics moderation])
    when "member"
      where(category: "content").where(name: %w[view_content create_content edit_content])
    when "viewer"
      where(category: "content").where(name: "view_content")
    else
      none
    end
  end
end
