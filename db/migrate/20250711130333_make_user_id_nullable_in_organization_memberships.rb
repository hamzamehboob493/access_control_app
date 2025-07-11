class MakeUserIdNullableInOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_memberships, :user_id, true
  end
end
