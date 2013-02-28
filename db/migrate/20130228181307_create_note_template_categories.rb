class CreateNoteTemplateCategories < ActiveRecord::Migration
  def change
    create_table :note_template_categories do |t|
      t.integer :account_id
      t.string :name

      t.timestamps
    end
  end
end
