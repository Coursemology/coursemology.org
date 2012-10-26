class UserCourse < ActiveRecord::Base
  attr_accessible :course_id, :exp, :role_id, :user_id

  belongs_to :role
end
