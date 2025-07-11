class AddVerificationFieldsToOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_memberships, :requested_at, :datetime
    add_column :organization_memberships, :approved_at, :datetime
    add_reference :organization_memberships, :approved_by, null: true, foreign_key: { to_table: :users }
    add_reference :organization_memberships, :invited_by, null: true, foreign_key: { to_table: :users }
    add_column :organization_memberships, :invitation_token, :string
    add_column :organization_memberships, :verification_method, :string
    add_column :organization_memberships, :verification_notes, :text

    add_index :organization_memberships, :invitation_token, unique: true
    add_index :organization_memberships, :requested_at
    add_index :organization_memberships, :approved_at
    add_index :organization_memberships, :verification_method
  end
end
