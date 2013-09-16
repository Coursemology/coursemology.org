class SurveySubmission < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :user_course_id, :survey_id, :open_at, :submitted_at, :status, :current_qn

  belongs_to :user_course
  belongs_to :survey
  has_many   :survey_mrq_answers, dependent: :destroy


  def set_started
    self.status = 'started'
    self.save
  end


  def set_submitted
    self.status = 'submitted'
    self.submitted_at = Time.now
    self.save
  end

  def started?
    self.status == 'started'
  end

  def submitted?
    self.status == 'submitted'
  end

  def done?
    (self.current_qn || 1) > self.survey.survey_questions.count
  end
end
