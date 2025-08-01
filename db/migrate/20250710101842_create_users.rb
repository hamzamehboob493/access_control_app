class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.string :phone_number, null: false
      t.string :email_verified_at
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :phone_number, unique: true
  end
end
