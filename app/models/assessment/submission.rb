class Assessment::Submission < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_submission

  belongs_to :assessment
  belongs_to :course, class_name: 'Course'
end
