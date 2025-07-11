class CreateParticipationRules < ActiveRecord::Migration[8.0]
  def change
    create_table :participation_rules do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :rule_type, null: false
      t.string :name, null: false
      t.text :description
      t.text :configuration
      t.boolean :active, default: true
      t.integer :priority, default: 1

      t.timestamps
    end

    add_index :participation_rules, [ :organization_id, :rule_type ]
    add_index :participation_rules, :active
    add_index :participation_rules, :priority
    add_index :participation_rules, [ :organization_id, :name ], unique: true
  end
end
