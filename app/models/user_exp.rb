class UserExp < ActiveRecord::Base
  attr_accessible :exp, :level_id, :user_course_id

  belongs_to :level
  belongs_to :user_course
end
