class Assessment::AnswerGrading < ActiveRecord::Base
  acts_as_paranoid

  belongs_to  :answer, class_name: Assessment::Answer
  belongs_to  :assessment_grading, class_name: Assessment::Grading
  has_many    :answer_grading_logs, class_name: Assessment::AnswerGradingLog, dependent: :destroy

end