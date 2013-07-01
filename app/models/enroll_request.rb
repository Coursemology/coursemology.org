class EnrollRequest < ActiveRecord::Base
  attr_accessible :course_id, :role_id, :user_id

  scope :student, where(:role_id => Role.student.first)

  belongs_to :course
  belongs_to :user
  belongs_to :role
end
