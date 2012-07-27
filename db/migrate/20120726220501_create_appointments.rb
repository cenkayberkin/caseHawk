class CreateAppointments < ActiveRecord::Migration
  def up
    create_table :appointments do |t|
      t.integer :creator_id, :null => false
      t.integer :owner_id
      t.integer :account_id
      t.integer :location_id
      t.string  :type, :null => false
      t.string  :name, :null => false
      t.boolean :remind
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :completed_at
      t.datetime :starts_at
      t.datetime :end_at
      t.datetime :deleted_at
      t.integer :completed_by
      t.integer :account_id
      t.integer :version
    end
  end

  def down
    drop_table :appointments
  end
end
