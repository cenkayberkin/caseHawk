class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string      :label
      t.references  :addressable, :polymorphic => true
      t.string      :street
      t.string      :unit
      t.string      :city, :limit => 50
      t.string      :postal_code, :limit => 10
      t.string      :state, :limit => 50
      t.timestamps
    end

  end

  def self.down
    drop_table :addresses
  end
end
