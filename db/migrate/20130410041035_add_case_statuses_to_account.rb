class AddCaseStatusesToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :case_statuses, :text
  end
end
