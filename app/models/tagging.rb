# == Schema Information
#
# Table name: taggings
#
#  id            :integer(4)      not null, primary key
#  creator_id    :integer(4)
#  tag_id        :integer(4)
#  taggable_type :string(255)
#  taggable_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  automated     :boolean(1)      not null
#

class Tagging < ActiveRecord::Base

  belongs_to :taggable, :polymorphic => true
  belongs_to :tag
  belongs_to :creator, :class_name => 'User'

  validates_presence_of :tag
  validates_presence_of :taggable
  validates_uniqueness_of :tag_id, :scope => [:taggable_type, :taggable_id]

  after_create :claim_account_from_taggable

  named_scope :automated,     :conditions => ["taggings.automated = ?", true]
  named_scope :not_automated, :conditions => ["taggings.automated = ?", false]

  protected

    def claim_account_from_taggable
      return unless taggable.respond_to?(:account)
      return unless account = taggable.account
      return unless tag.account.blank?
      tag.update_attribute(:account, account)
    end

  # This module is used to extend the :taggings associations
  # on taggable records. Any methods added to Extension will
  # be available to the Event#taggings object like so:
  #
  #   @event.taggings.tags => # list of tags
  #   @event.taggings.tags=('one two') => # saves 'one two' as tags
  #
  # To make this more intuitive you can delagate the tags and tags=
  # methods to the association like so:
  #
  #   has_many :taggings, :as => :taggable
  #   delegate :tags,  :to => :taggings
  #   delegate :tags=, :to => :taggings
  #
  # Then:
  #
  #   @event.tags    == @event.taggings.tags
  #   @event.tags=() == @event.taggings.tags=()
  #
  module Extension

    # this method just returns the event, case, etc. that is taggable
    def taggable
      @owner
    end

    # reads the tag records and returns a string of the tag names
    def tags
      TagParser.un_parse taggable.tag_records.map(&:name)
    end

    # Ask the taggable object for a list of records that are related
    # to it. Iterate through those records for viable tag names and
    # create a tagging for each one
    def automatic_update
      # if the taggable hasn't set up related_records() yet then
      # just use the taggable itself
      related_records = taggable.respond_to?(:related_records) ?
                          taggable.related_records :
                          [taggable]

      names = related_records.inject([]) do |injector, record|
        injector << record.name        if record.respond_to?(:name)
        injector << record.description if record.respond_to?(:description)
        injector << record.title       if record.respond_to?(:title)
        injector
      end

      automated.delete_all

      names.flatten.uniq.compact.each do |name|
        tag = Tag.find_or_create_by_name(name)
        create :tag => tag, :automated => true
      end

      # return this association, reloaded
      taggable.taggings(:reload)
    end
  end
end
