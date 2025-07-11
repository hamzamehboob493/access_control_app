class AddInvitedEmailToOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_memberships, :invited_email, :string
  end
end
