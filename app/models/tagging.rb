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

  protected

    def claim_account_from_taggable
      return unless taggable.respond_to?(:account)
      return unless account = taggable.account
      return unless tag.account.blank?
      tag.update_attribute(:account, account)
    end
end
