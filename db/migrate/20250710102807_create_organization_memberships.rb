class CreateOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.string :role, null: false, default: 'member'
      t.string :status, null: false, default: 'pending'
      t.datetime :joined_at
      t.timestamps
    end

    add_index :organization_memberships, [ :user_id, :organization_id ], unique: true
    add_index :organization_memberships, [ :organization_id, :role ]
    add_index :organization_memberships, :status
  end
end
