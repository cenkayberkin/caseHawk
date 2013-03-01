class AddTypeToCase < ActiveRecord::Migration
  def change
    add_column :cases, :case_type, :string
  end
end
