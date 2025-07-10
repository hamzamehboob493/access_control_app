class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.text :description
      t.string :organization_type, null: false
      t.string :registration_number
      t.string :website
      t.datetime :verified_at
      t.timestamps
    end

    add_index :organizations, :name, unique: true
    add_index :organizations, :organization_type
  end
end
