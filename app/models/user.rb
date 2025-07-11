class User < ApplicationRecord
  has_secure_password validations: false

  # Associations
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_one :parental_consent, dependent: :destroy
  belongs_to :invited_by, class_name: "User", optional: true
  has_many :invited_users, class_name: "User", foreign_key: :invited_by_id

  # Validations - conditional based on profile completion
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :first_name, :last_name, :date_of_birth, presence: true, if: :profile_completed?
  validates :phone_number, presence: true, uniqueness: true, format: {
    with: /\A[\+]?[1-9][\d]{0,15}\z/,
    message: "must be a valid phone number (10-15 digits, optional country code)"
  }, if: :profile_completed?
  validate :date_of_birth_cannot_be_in_the_future, if: :date_of_birth_present?
  validate :phone_number_format, if: :phone_number_present?

  # Scopes
  scope :verified, -> { where.not(email_verified_at: nil) }
  scope :minors, -> { where("date_of_birth > ?", Date.today - 18.years) }
  scope :adults, -> { where("date_of_birth < ?", Date.today - 18.years) }
  scope :invited, -> { where.not(invitation_token: nil) }
  scope :profile_completed, -> { where(profile_completed: true) }

  # Invitation methods
  def self.invite!(email, invited_by_user = nil)
    user = find_or_initialize_by(email: email.downcase.strip)

    if user.persisted? && user.profile_completed?
      raise "User already exists and has completed profile"
    end

    # Generate new invitation token (even for existing pending users)
    user.invitation_token = SecureRandom.urlsafe_base64(32)
    user.invited_by = invited_by_user if invited_by_user.present?
    user.profile_completed = false
    user.invitation_accepted_at = nil  # Reset acceptance timestamp for re-invites
    user.save!(validate: false)

    user
  end

  def accept_invitation!(attributes = {})
    transaction do
      update!(attributes.merge(
        invitation_accepted_at: Time.current,
        invitation_token: nil,
        profile_completed: true
      ))
    end
  end

  def invited?
    invitation_token.present?
  end

  def invitation_accepted?
    invitation_accepted_at.present?
  end

  def invitation_pending?
    invited? && !invitation_accepted?
  end

  def profile_completed?
    profile_completed == true
  end

  def age
    return nil unless date_of_birth

    ((Date.current - date_of_birth) / 365.25).floor
  end

  def minor?
    age < 18
  end

  def age_group
    case age
    when 0..12 then "Child"
    when 13..17 then "Teen"
    when 18..64 then "Adult"
    else "Senior"
    end
  end

  def requires_parental_consent?
    minor?
  end

  def parental_consent_valid?
    return true unless requires_parental_consent?
    parental_consent&.valid_consent?
  end

  def admin_of?(organization)
    organization_memberships.exists?(organization: organization, role: "admin")
  end

  def admin_of_any_organization?
    organization_memberships.where(role: "admin").exists?
  end

  # Format phone number for display
  def formatted_phone_number
    return phone_number unless phone_number.present?

    # Remove all non-digit characters
    digits = phone_number.gsub(/\D/, "")

    # Format as US phone number if 10 digits
    if digits.length == 10
      "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}"
    elsif digits.length == 11 && digits[0] == "1"
      "+1 (#{digits[1..3]}) #{digits[4..6]}-#{digits[7..10]}"
    else
      phone_number
    end
  end

  private

  def password_required?
    # Password is required if it's a new record or password is being changed
    # But not required for invitation flow until profile is completed
    return false if invitation_pending?
    new_record? || password.present?
  end

  def date_of_birth_present?
    date_of_birth.present?
  end

  def phone_number_present?
    phone_number.present?
  end

  def date_of_birth_cannot_be_in_the_future
    return unless date_of_birth

    errors.add(:date_of_birth, "cannot be in the future") if date_of_birth > Date.today
  end

  def phone_number_format
    return unless phone_number.present?

    # Remove all non-digit characters for validation
    digits = phone_number.gsub(/\D/, "")

    # Check if it's a valid length (10-15 digits)
    if digits.length < 10 || digits.length > 15
      errors.add(:phone_number, "must be between 10 and 15 digits")
      return
    end

    # Check for US phone number format (10 digits or 11 with country code 1)
    if digits.length == 10
      # Valid US phone number
      if digits[0] == "0" || digits[0] == "1"
        errors.add(:phone_number, "area code cannot start with 0 or 1")
      end
    elsif digits.length == 11
      # Check if it starts with 1 (US country code)
      unless digits[0] == "1"
        errors.add(:phone_number, "11-digit numbers must start with 1 (US country code)")
      end
      # Check area code
      if digits[1] == "0" || digits[1] == "1"
        errors.add(:phone_number, "area code cannot start with 0 or 1")
      end
    end

    # Normalize the phone number (remove formatting, keep only digits)
    self.phone_number = digits
  end
end
