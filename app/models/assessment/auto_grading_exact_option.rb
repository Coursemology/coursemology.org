class Assessment::AutoGradingExactOption < ActiveRecord::Base
  validates :answer, presence: true
  validates :explanation, presence: true

  attr_accessible :general_question_id
  attr_accessible :correct, :answer, :explanation

  belongs_to :general_question
end
