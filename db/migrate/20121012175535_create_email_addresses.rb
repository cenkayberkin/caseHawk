class CreateEmailAddresses < ActiveRecord::Migration
  def change
    create_table :email_addresses do |t|
      t.string :email
      t.string :label
      t.integer :contact_id

      t.timestamps
    end
  end
end
