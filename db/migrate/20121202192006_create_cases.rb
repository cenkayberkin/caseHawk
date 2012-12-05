class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.integer :user_id
      t.string  :title
      t.string  :current_status
      t.text    :case_number_details
      t.text    :general_case_details
      t.string  :referral
      t.text    :referral_details
      t.string  :legal_plan
      t.text    :legal_plan_details
      t.string  :important_date
      t.text    :important_date_details

      t.timestamps
    end
  end
end
