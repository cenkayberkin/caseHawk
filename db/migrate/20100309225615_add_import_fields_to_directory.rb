class AddImportFieldsToDirectory < ActiveRecord::Migration
  def self.up
    add_column :events, :uri, :string
    add_column :events, :recurrance, :text
    add_column :events, :uid, :string
    marcc
  end

  def self.down
    remove_column :events, :uid
    remove_column :events, :column_name
    remove_column :events, :uri
  end
end