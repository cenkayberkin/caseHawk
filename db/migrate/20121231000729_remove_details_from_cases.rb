class RemoveDetailsFromCases < ActiveRecord::Migration
  def change
    remove_column :cases, :case_number_details
    remove_column :cases, :general_case_details
  end
end
