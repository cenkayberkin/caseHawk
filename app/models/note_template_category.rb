class NoteTemplateCategory < ActiveRecord::Base
  attr_accessible :name, :note_templates_attributes

  belongs_to :account
  has_many :note_templates

  accepts_nested_attributes_for :note_templates, :allow_destroy => true,
                                :reject_if => proc { |a| a['template'].blank? }
end
