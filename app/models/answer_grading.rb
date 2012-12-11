class AnswerGrading < ActiveRecord::Base
  attr_accessible :comment, :grade, :grader_id, :student_answer_id, :submission_grading_id
end
