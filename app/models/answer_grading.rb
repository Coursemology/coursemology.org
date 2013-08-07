class AnswerGrading < ActiveRecord::Base
  attr_accessible :comment, :grade, :grader_id, :student_answer_id,
      :student_answer_type, :submission_grading_id, :exp

  belongs_to :submission_grading
  belongs_to :student_answer, polymorphic: true
  belongs_to :grader, class_name: "User"
end
