class CaseContact < ActiveRecord::Base
  belongs_to :case
  belongs_to :contact
end
