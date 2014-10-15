class Assessment::AnswerGradingLog  < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :grader, class_name: User
  belongs_to :grader_course, class_name: UserCourse
  belongs_to :answer_grading, class_name: Assessment::AnswerGrading
end