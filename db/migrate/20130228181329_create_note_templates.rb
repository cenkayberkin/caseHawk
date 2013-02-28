class CreateNoteTemplates < ActiveRecord::Migration
  def change
    create_table :note_templates do |t|
      t.integer :note_template_category_id
      t.string :template

      t.timestamps
    end
  end
end
