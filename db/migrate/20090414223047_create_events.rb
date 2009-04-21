class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      
      t.integer     :creator_id, :null => false
      t.integer     :owner_id
      t.references  :location
      t.string      :kind, :null => false
      t.string      :name, :null => false
      t.date        :start_date
      t.time        :start_time
      t.date        :end_date
      t.time        :end_time
      t.boolean     :remind, :default => false
      
      t.timestamps
    end

  end

  def self.down
    drop_table :events
  end
end
