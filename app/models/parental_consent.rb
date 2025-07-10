class ParentalConsent < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :parent_name, :parent_email, presence: true
  validates :parent_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :consent_method, inclusion: { in: %w[email phone in_person] }

  # Scopes
  scope :valid_consents, -> { where("consent_given_at IS NOT NULL AND (expires_at IS NULL OR expires_at > ?)", Time.current) }

  # Methods
  def valid_consent?
    consent_given_at.present? && (expires_at.nil? || expires_at > Time.current)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def generate_verification_token
    self.verification_token = SecureRandom.urlsafe_base64(32)
  end
end
