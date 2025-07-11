class AddLastInvitedAtToOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_memberships, :last_invited_at, :datetime
  end
end
