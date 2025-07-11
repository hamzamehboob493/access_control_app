class Organization < ApplicationRecord
  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships
  has_many :participation_rules, dependent: :destroy
  has_many :rule_violations, dependent: :destroy

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
                                .transform_values(&:count),
      rule_violations: rule_violations.group(:violation_type).count,
      active_rules: participation_rules.active.count
    }
  end

  def evaluate_participation_rules(user, context = {})
    active_rules = participation_rules.active.by_priority
    violations = []

    active_rules.each do |rule|
      unless rule.evaluate_for_user(user, context)
        violation_type = "#{rule.rule_type.gsub('_restriction', '')}_violation"
        violation = RuleViolation.create_violation(user, self, rule, violation_type)
        violations << violation
      end
    end

    violations
  end

  def can_user_participate?(user, context = {})
    violations = evaluate_participation_rules(user, context)
    violations.empty?
  end

  def participation_summary_for_user(user)
    {
      can_participate: can_user_participate?(user),
      active_rules: participation_rules.active.count,
      violations: RuleViolation.violation_summary_for_user(user, self),
      applicable_rules: participation_rules.active.select { |rule| !rule.evaluate_for_user(user) }
    }
  end

  def create_default_participation_rules
    # Age-based rule for minors
    participation_rules.find_or_create_by(
      rule_type: "age_restriction",
      name: "Minor Supervision Required"
    ) do |rule|
      rule.description = "Users under 18 require additional supervision"
      rule.configuration = {
        min_age: 13,
        max_age: 17,
        violation_message: "Minors require additional supervision for this activity",
        severity: "medium",
        can_override: true
      }
      rule.priority = 1
    end

    # Time-based rule for business hours
    participation_rules.find_or_create_by(
      rule_type: "time_restriction",
      name: "Business Hours Only"
    ) do |rule|
      rule.description = "Participation limited to business hours"
      rule.configuration = {
        allowed_days: %w[monday tuesday wednesday thursday friday],
        allowed_hours: { start: 9, end: 17 },
        violation_message: "Participation is only allowed during business hours",
        severity: "low",
        can_override: true
      }
      rule.priority = 2
      rule.active = false # Disabled by default
    end

    # Role-based rule for managers and admins
    participation_rules.find_or_create_by(
      rule_type: "role_restriction",
      name: "Manager Access Only"
    ) do |rule|
      rule.description = "Certain actions require manager or admin role"
      rule.configuration = {
        required_roles: %w[manager admin],
        violation_message: "This action requires manager or admin privileges",
        severity: "high",
        can_override: false
      }
      rule.priority = 3
      rule.active = false # Disabled by default
    end
  end
end
