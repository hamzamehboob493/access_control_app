class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false

      t.timestamps
    end

    add_index :permissions, :name, unique: true
    add_index :permissions, :category
  end
end
