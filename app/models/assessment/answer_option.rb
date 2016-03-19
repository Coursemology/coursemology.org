class Assessment::AnswerOption < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :option_id, :answer_id

  belongs_to  :answer, class_name: Assessment::McqAnswer.name
  belongs_to  :option, class_name: Assessment::McqOption.name
end