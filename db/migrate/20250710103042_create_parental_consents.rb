class CreateParentalConsents < ActiveRecord::Migration[8.0]
  def change
    create_table :parental_consents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :parent_name, null: false
      t.string :parent_email, null: false
      t.string :parent_phone
      t.datetime :consent_given_at
      t.string :consent_method
      t.string :verification_token
      t.datetime :expires_at
      t.timestamps
    end

    add_index :parental_consents, :verification_token
  end
end
