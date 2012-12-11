class AnswerGrading < ActiveRecord::Base
  attr_accessible :comment, :grade, :grader_id, :student_answer_id, :submission_grading_id

  belongs_to :submission_grading
  belongs_to :student_answer
  belongs_to :grader, class_name: "User"
end
