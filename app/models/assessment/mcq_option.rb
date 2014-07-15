class Assessment::McqOption < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :correct, :text, :explanation

  belongs_to :question, class_name: Assessment::Question
  has_many   :answer_options, class_name: Assessment::AnswerOption

end