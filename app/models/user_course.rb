class UserCourse < ActiveRecord::Base
  attr_accessible :course_id, :exp, :role_id, :user_id

  belongs_to :role
  belongs_to :user
  belongs_to :course
end
