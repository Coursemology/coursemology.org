class Assessment::Grading < ActiveRecord::Base
  acts_as_paranoid

  has_many  :answer_gradings, class_name: Assessment::AnswerGrading
  has_many  :grading_logs, class_name: Assessment::GradingLog, dependent: :destroy
end