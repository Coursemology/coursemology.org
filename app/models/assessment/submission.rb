class Assessment::Submission < ActiveRecord::Base
  acts_as_superclass as: :as_assessment_submission

  belongs_to :assessment
  belongs_to :course, class_name: 'Course'
  belongs_to :std_course, class_name: 'UserCourse'

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

  def set_attempting
    status = STATUS_ATTEMPTING
  end
  alias_method :attempt, :set_attempting
  alias_method :attempt_mission, :set_attempting

  def set_submitted(redirect_url)
    status = STATUS_SUBMITTED
    submitted_at = updated_at
    notify_submission(redirect_url)
  end

  def set_graded
    status = STATUS_GRADED
  end
end
