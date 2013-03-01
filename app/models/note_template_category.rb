class NoteTemplateCategory < ActiveRecord::Base
  attr_accessible :name

  belongs_to :account
  has_many :note_templates

  accepts_nested_attributes_for :note_templates
end
