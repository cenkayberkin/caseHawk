class AddImportFieldsToDirectory < ActiveRecord::Migration
  def up
    add_column :events, :uri, :string
    add_column :events, :recurrance, :text
    add_column :events, :uid, :string
  end

  def down
    remove_column :events, :uid
    remove_column :events, :column_name
    remove_column :events, :uri
  end
end
