class Assessment::QuestionSubmission < ActiveRecord::Base
  acts_as_superclass

  belongs_to :submission
  belongs_to :question
end
