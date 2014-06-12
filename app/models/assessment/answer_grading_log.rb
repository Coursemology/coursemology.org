class Assessment::AnswerGradingLog  < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :answer_grading, class_name: Assessment::AnswerGrading
end