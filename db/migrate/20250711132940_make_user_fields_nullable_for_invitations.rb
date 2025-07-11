class MakeUserFieldsNullableForInvitations < ActiveRecord::Migration[8.0]
  def change
    # Make most fields nullable to support invitation flow
    change_column_null :users, :first_name, true
    change_column_null :users, :last_name, true
    change_column_null :users, :date_of_birth, true
    change_column_null :users, :phone_number, true
    change_column_null :users, :password_digest, true

    # Add invitation-related fields
    add_column :users, :invitation_token, :string
    add_column :users, :invitation_accepted_at, :datetime
    add_column :users, :invited_by_id, :integer
    add_column :users, :profile_completed, :boolean, default: false

    # Add indexes for invitation fields
    add_index :users, :invitation_token, unique: true
    add_index :users, :invited_by_id

    # Add foreign key for invited_by
    add_foreign_key :users, :users, column: :invited_by_id
  end
end
