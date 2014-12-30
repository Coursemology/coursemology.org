class Scribble < ActiveRecord::Base

	belongs_to :answer, class_name: "Assessment::ScribingAnswer"
  belongs_to :std_course, class_name: "UserCourse"
  has_one :user, through: :std_course

  attr_accessible :content, :user, :answer
  attr_accessible :std_course_id, :scribing_answer_id, :id
  
end
