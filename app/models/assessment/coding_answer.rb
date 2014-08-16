class Assessment::CodingAnswer < ActiveRecord::Base
  acts_as_paranoid
  is_a :answer, as: :as_answer, auto_join: false, class_name: "Assessment::Answer"

  attr_accessible :std_course_id, :question_id, :content, :submission_id, :attempt_left

  def result_hash
    self.result ? JSON.parse(self.result) : {}
  end
end


