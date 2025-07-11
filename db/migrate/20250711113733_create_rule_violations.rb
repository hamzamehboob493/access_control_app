class CreateRuleViolations < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_violations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.references :participation_rule, null: false, foreign_key: true
      t.string :violation_type, null: false
      t.text :details
      t.boolean :resolved, default: false
      t.datetime :resolved_at
      t.references :resolved_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :rule_violations, [ :user_id, :organization_id ]
    add_index :rule_violations, :resolved
    add_index :rule_violations, :violation_type
    add_index :rule_violations, :created_at
  end
end
