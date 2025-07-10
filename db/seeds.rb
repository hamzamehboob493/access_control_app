# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb
# Create age groups
age_groups = [
  { name: 'Children', min_age: 0, max_age: 12, requires_parental_consent: true },
  { name: 'Teens', min_age: 13, max_age: 17, requires_parental_consent: true },
  { name: 'Young Adults', min_age: 18, max_age: 25, requires_parental_consent: false },
  { name: 'Adults', min_age: 26, max_age: 64, requires_parental_consent: false },
  { name: 'Seniors', min_age: 65, max_age: 120, requires_parental_consent: false }
]

age_groups.each do |group|
  AgeGroup.find_or_create_by(name: group[:name]) do |ag|
    ag.assign_attributes(group)
  end
end

# Create test users for login testing
puts "Creating test users..."

# Adult user (for full access testing)
adult_user = User.find_or_create_by(email: 'adult@example.com') do |user|
  user.first_name = 'John'
  user.last_name = 'Doe'
  user.phone_number = '5551234567'
  user.date_of_birth = 30.years.ago.to_date
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# Minor user (for parental consent testing)
minor_user = User.find_or_create_by(email: 'minor@example.com') do |user|
  user.first_name = 'Jane'
  user.last_name = 'Smith'
  user.phone_number = '5559876543'
  user.date_of_birth = 16.years.ago.to_date
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# Create sample organizations
tech_org = Organization.find_or_create_by(name: 'Tech Innovation Corp') do |org|
  org.organization_type = 'company'
end

nonprofit_org = Organization.find_or_create_by(name: 'Community Health Foundation') do |org|
  org.organization_type = 'nonprofit'
end

# Create organization memberships
if adult_user.persisted? && tech_org.persisted?
  OrganizationMembership.find_or_create_by(
    user: adult_user,
    organization: tech_org
  ) do |membership|
    membership.role = 'admin'
    membership.status = 'active'
  end
end

if minor_user.persisted? && nonprofit_org.persisted?
  OrganizationMembership.find_or_create_by(
    user: minor_user,
    organization: nonprofit_org
  ) do |membership|
    membership.role = 'member'
    membership.status = 'active'
  end
end

puts "Test users created successfully!"
puts "Adult user: adult@example.com / password123"
puts "Minor user: minor@example.com / password123"
puts "Organizations: #{Organization.count} created"
puts "Memberships: #{OrganizationMembership.count} created"
