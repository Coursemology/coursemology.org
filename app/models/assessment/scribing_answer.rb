class Assessment::ScribingAnswer < ActiveRecord::Base
  acts_as_paranoid
  is_a :answer, as: :as_answer, auto_join: false, class_name: "Assessment::Answer"
  has_many :scribbles, dependent: :destroy

  attr_accessible :std_course_id, :question_id, :content, :submission_id, :attempt_left

end


