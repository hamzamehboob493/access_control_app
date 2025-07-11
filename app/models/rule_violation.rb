class RuleViolation < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :organization
  belongs_to :participation_rule
  belongs_to :resolved_by, class_name: "User", optional: true

  # Validations
  validates :violation_type, presence: true
  validates :violation_type, inclusion: { in: %w[age_violation time_violation role_violation content_violation custom_violation] }

  # Scopes
  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :by_type, ->(type) { where(violation_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def resolve!(resolver, resolution_notes = nil)
    update!(
      resolved: true,
      resolved_at: Time.current,
      resolved_by: resolver,
      details: [ details, "Resolved: #{resolution_notes}" ].compact.join("\n")
    )
  end

  def severity
    participation_rule.severity
  end

  def auto_resolvable?
    participation_rule.can_override?
  end

  def formatted_details
    details.presence || "Rule '#{participation_rule.name}' was violated"
  end

  # Class methods
  def self.create_violation(user, organization, rule, type, details = nil)
    create!(
      user: user,
      organization: organization,
      participation_rule: rule,
      violation_type: type,
      details: details || rule.violation_message
    )
  end

  def self.violation_summary_for_user(user, organization)
    violations = where(user: user, organization: organization)
    {
      total: violations.count,
      unresolved: violations.unresolved.count,
      by_type: violations.group(:violation_type).count,
      recent: violations.recent.limit(5)
    }
  end
end
