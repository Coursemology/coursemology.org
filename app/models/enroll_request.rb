class EnrollRequest < ActiveRecord::Base
  attr_accessible :course_id, :role_id, :user_id

  include Rails.application.routes.url_helpers
  scope :student, where(:role_id => Role.student.first)

  belongs_to :course
  belongs_to :user
  belongs_to :role

  before_save :notify_lecturer

  def notify_lecturer
    course.lect_courses.each do |uc|
      UserMailer.delay.new_enroll_request(self,uc.user, new_course_enroll_request_path(course))
    end
  end
end
