class CreateAgeGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :age_groups do |t|
      t.string :name, null: false
      t.integer :min_age, null: false
      t.integer :max_age, null: false
      t.boolean :requires_parental_consent, default: false
      t.timestamps
    end

    add_index :age_groups, :name, unique: true
    add_index :age_groups, [ :min_age, :max_age ]
  end
end
