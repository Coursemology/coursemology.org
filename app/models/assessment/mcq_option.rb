class Assessment::McqOption < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :question, class_name: Assessment::Question
  has_many   :answer_options, class_name: Assessment::AnswerOption

end