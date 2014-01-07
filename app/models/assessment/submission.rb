class Assessment::Submission < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_submission

  belongs_to :assessment
  belongs_to :course, class_name: 'Course'

  STATUS_ATTEMPTING = 'attempting'
  STATUS_SUBMITTED = 'submitted'
  STATUS_GRADED = 'graded'

  def attempting?
    self.status == STATUS_ATTEMPTING
  end

  def submitted?
    self.status == STATUS_SUBMITTED
  end

  def graded?
    self.status == STATUS_GRADED
  end
end
