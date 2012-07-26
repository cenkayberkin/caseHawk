class CreateLocations < ActiveRecord::Migration
  def up
    create_table :locations do |t|
      t.references  :event
      t.string      :name, :limit => 50
      t.timestamps
    end
  end

  def down
    drop_table :locations
  end
end
