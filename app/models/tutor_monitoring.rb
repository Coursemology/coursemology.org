class TutorMonitoring < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :course_id, :user_course_id, :average_time, :std_dev

  belongs_to :course
  belongs_to :user_course

end
