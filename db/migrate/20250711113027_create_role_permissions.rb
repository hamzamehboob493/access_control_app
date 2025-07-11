class CreateRolePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :role_permissions do |t|
      t.references :organization_membership, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true

      t.timestamps
    end

    add_index :role_permissions, [ :organization_membership_id, :permission_id ],
              unique: true,
              name: 'index_role_permissions_on_membership_and_permission'
  end
end
