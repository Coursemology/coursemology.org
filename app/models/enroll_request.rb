class EnrollRequest < ActiveRecord::Base
  attr_accessible :course_id, :role_id, :user_id
end
