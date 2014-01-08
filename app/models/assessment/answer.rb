class Assessment::Answer < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_answer

  belongs_to :submission
  belongs_to :question
end
