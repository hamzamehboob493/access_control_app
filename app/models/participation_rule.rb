class ParticipationRule < ApplicationRecord
  # Associations
  belongs_to :organization
  has_many :rule_violations, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :rule_type, presence: true
  validates :rule_type, inclusion: { in: %w[age_restriction time_restriction role_restriction content_filter custom] }
  validates :priority, presence: true, numericality: { greater_than: 0 }
  validates :configuration, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(rule_type: type) }
  scope :by_priority, -> { order(:priority) }

  # Serialization
  serialize :configuration, coder: JSON

  # Constants
  RULE_TYPES = {
    "age_restriction" => "Age-based participation restrictions",
    "time_restriction" => "Time-based participation restrictions",
    "role_restriction" => "Role-based participation restrictions",
    "content_filter" => "Content filtering rules",
    "custom" => "Custom organization-specific rules"
  }.freeze

  # Instance methods
  def evaluate_for_user(user, context = {})
    return true unless active?

    case rule_type
    when "age_restriction"
      evaluate_age_restriction(user)
    when "time_restriction"
      evaluate_time_restriction(user, context)
    when "role_restriction"
      evaluate_role_restriction(user, context)
    when "content_filter"
      evaluate_content_filter(user, context)
    when "custom"
      evaluate_custom_rule(user, context)
    else
      true
    end
  end

  def violation_message
    configuration.dig("violation_message") || "Participation rule '#{name}' violated"
  end

  def can_override?
    configuration.dig("can_override") || false
  end

  def severity
    configuration.dig("severity") || "medium"
  end

  private

  def evaluate_age_restriction(user)
    min_age = configuration.dig("min_age")
    max_age = configuration.dig("max_age")

    return true if min_age.nil? && max_age.nil?

    user_age = user.age
    return false if min_age && user_age < min_age
    return false if max_age && user_age > max_age

    true
  end

  def evaluate_time_restriction(user, context)
    allowed_days = configuration.dig("allowed_days") || []
    allowed_hours = configuration.dig("allowed_hours") || {}

    current_time = Time.current

    # Check day restriction
    if allowed_days.any? && !allowed_days.include?(current_time.strftime("%A").downcase)
      return false
    end

    # Check hour restriction
    if allowed_hours.any?
      current_hour = current_time.hour
      start_hour = allowed_hours["start"]
      end_hour = allowed_hours["end"]

      if start_hour && end_hour
        if start_hour <= end_hour
          return false unless current_hour >= start_hour && current_hour <= end_hour
        else
          # Handle overnight restrictions (e.g., 22:00 to 06:00)
          return false unless current_hour >= start_hour || current_hour <= end_hour
        end
      end
    end

    true
  end

  def evaluate_role_restriction(user, context)
    required_roles = configuration.dig("required_roles") || []
    forbidden_roles = configuration.dig("forbidden_roles") || []

    user_membership = user.organization_memberships.find_by(organization: organization, status: "active")
    return false unless user_membership

    user_role = user_membership.role

    # Check required roles
    if required_roles.any? && !required_roles.include?(user_role)
      return false
    end

    # Check forbidden roles
    if forbidden_roles.any? && forbidden_roles.include?(user_role)
      return false
    end

    true
  end

  def evaluate_content_filter(user, context)
    # This would typically check against content being posted/accessed
    # For now, we'll implement basic keyword filtering
    content = context[:content] || context[:message] || ""

    blocked_words = configuration.dig("blocked_words") || []
    required_words = configuration.dig("required_words") || []

    # Check for blocked words
    if blocked_words.any?
      blocked_words.each do |word|
        return false if content.downcase.include?(word.downcase)
      end
    end

    # Check for required words
    if required_words.any?
      required_words.each do |word|
        return false unless content.downcase.include?(word.downcase)
      end
    end

    true
  end

  def evaluate_custom_rule(user, context)
    # Custom rules would be implemented based on organization needs
    # For now, we'll return true (no restrictions)
    true
  end
end
