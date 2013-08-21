class PendingComments < ActiveRecord::Base
  attr_accessible :answer_id, :answer_type, :pending, :course_id

  belongs_to :course
  belongs_to :answer, polymorphic: true
end
