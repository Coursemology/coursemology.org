class Assessment::AnswerOption < ActiveRecord::Base
  acts_as_paranoid

  belongs_to  :answer, class_name: Assessment::Answer
  belongs_to  :option, class_name: Assessment::McqOption

end