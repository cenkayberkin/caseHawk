class CreateCaseContacts < ActiveRecord::Migration
  def change
    create_table :case_contacts do |t|
      t.integer :case_id
      t.integer :contact_id
      t.string  :role

      t.timestamps
    end
  end
end
