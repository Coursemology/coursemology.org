class Assessment::QuestionSubmission < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_question_submission

  belongs_to :submission
  belongs_to :question
end
