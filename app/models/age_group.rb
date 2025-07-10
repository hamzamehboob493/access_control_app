class AgeGroup < ApplicationRecord
  # Associations
  has_many :participation_spaces, dependent: :destroy
  has_many :content_filters, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :min_age, :max_age, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :max_age_greater_than_min_age

  # Scopes
  scope :requiring_consent, -> { where(requires_parental_consent: true) }

  # Class methods
  def self.find_by_age(age)
    where("min_age <= ? AND max_age >= ?", age, age).first
  end

  private

  def max_age_greater_than_min_age
    return unless min_age && max_age
    errors.add(:max_age, "must be greater than minimum age") if max_age <= min_age
  end
end
