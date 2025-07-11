# Preview all emails at http://localhost:3000/rails/mailers/organization_mailer_mailer
class OrganizationMailerPreview < ActionMailer::Preview
  def invitation_email
    # Create sample data for preview
    organization = Organization.first || Organization.new(
      name: "Tech Innovators Inc.",
      organization_type: "company",
      description: "A cutting-edge technology company focused on innovative solutions."
    )

    invited_by = User.first || User.new(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com"
    )

    # Create a sample user for the invitation
    user = User.new(
      email: "newuser@example.com",
      invitation_token: "sample_invitation_token_123"
    )

    membership = OrganizationMembership.new(
      organization: organization,
      user: user,
      invited_by: invited_by,
      role: "member",
      verification_method: "invitation",
      invitation_token: "sample_invitation_token_123",
      invited_email: "newuser@example.com"
    )

    invitation_url = "http://localhost:3000/invitations/sample_invitation_token_123"

    OrganizationMailer.invitation_email(membership, "newuser@example.com", invitation_url)
  end
end
