class SurveySubmission < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :user_course_id, :survey_id, :open_at, :submitted_at, :status, :current_qn

  belongs_to :user_course
  belongs_to :survey
  has_many   :survey_mrq_answers, dependent: :destroy
  has_many   :survey_essay_answers, dependent: :destroy
  belongs_to :exp_transaction

  default_scope includes(:user_course)


  def set_started
    self.status = 'started'
    self.save
  end

  def get_answer(qn)
    if qn.is_essay?
      survey_essay_answers.where(question_id: qn)
    else
      survey_mrq_answers.where(question_id: qn)
    end
  end


  def set_submitted
    if !submitted? and survey.exp.to_i > 0
      self.exp_transaction = ExpTransaction.new
      self.exp_transaction.user_course = self.user_course
      self.exp_transaction.reason = "Exp for #{survey.title}"
      self.exp_transaction.is_valid = true
      self.exp_transaction.exp = survey.exp
      self.save
      self.exp_transaction.update_user_data
    end

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
