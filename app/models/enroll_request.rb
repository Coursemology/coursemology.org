class EnrollRequest < ActiveRecord::Base
  attr_accessible :course_id, :role_id, :user_id

  include Rails.application.routes.url_helpers
  scope :student, where(:role_id => Role.student.first)

  belongs_to :course
  belongs_to :user
  belongs_to :role


  def notify_lecturer(redirect_url)
    puts "lect courses", course.lect_courses
    course.lect_courses.each do |uc|
      UserMailer.delay.new_enroll_request(self, uc.user, redirect_url)
    end
  end
end
