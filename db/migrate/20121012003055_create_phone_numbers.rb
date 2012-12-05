class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.string :number
      t.string :label
      t.integer :contact_id

      t.timestamps
    end
  end
end
