class OrganizationMailer < ApplicationMailer
  default from: "noreply@accesscontrolapp.com"

  def invitation_email(membership, invited_email, invitation_url)
    @membership = membership
    @organization = membership.organization
    @invited_by = membership.invited_by
    @invited_email = invited_email
    @invitation_url = invitation_url
    @role = membership.role
    @user = membership.user

    mail(
      to: invited_email,
      subject: "You're invited to join #{@organization.name}"
    )
  end
end
