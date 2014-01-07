class Assessment::Question < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_question

  belongs_to :assessment
end
