class NoteTemplate < ActiveRecord::Base
  attr_accessible :template

  belongs_to :note_template_category
end
