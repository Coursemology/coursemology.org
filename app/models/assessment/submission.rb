class Assessment::Submission < ActiveRecord::Base
  acts_as_paranoid

  scope :mission_submissions,
         joins("left join assessments on assessment_submissions.assessment_id = assessments.id ").
         where("assessments.as_assessment_type = 'Assessment::Mission'")

  scope :training_submissions,
        joins("left join assessments on assessment_submissions.assessment_id = assessments.id ").
            where("assessments.as_assessment_type = 'Assessment::Training'")

  belongs_to :assessment
  belongs_to :std_course, class_name: "UserCourse"
  has_many :answers, class_name: Assessment::Answer, dependent: :destroy
  has_many :gradings, class_name: Assessment::Grading, dependent: :destroy

  def get_final_grading
    if self.gradings.length > 0
      self.gradings.last
    else
      nil
    end
  end

  def get_all_answers
    self.answers
  end

  #TODO
  def clear_final_answer(qn)
    self.answers.final.each do |sbm_ans|
      if sbm_ans.qn == qn
        sbm_ans.final = false
        sbm_ans.save
        break
      end
    end
  end

  def has_multiplier?
    self.respond_to?(:multiplier) && self.multiplier
  end

  def get_bonus
    if self.assessment.respond_to? :bonus_cutoff
      if  self.assessment.bonus_cutoff && self.assessment.bonus_cutoff > Time.now
        return self.assessment.bonus_exp
      end
    end
    0
  end

  def set_attempting
    self.update_attribute(:status,'attempting')
  end

  #TODO
  def set_submitted(redirect_url = "", notify = true)
    self.update_attribute(:status,'submitted')
    self.update_attribute(:submit_at, updated_at)

    if self.class == Submission
      pending_action = std_course.pending_actions.where(item_type: Mission.to_s, item_id: self.mission.id).first
      pending_action.set_done if pending_action

      notify_submission(redirect_url) if notify
    end
  end

  def set_graded
    self.update_attribute(:status,'graded')
  end

  def attempting?
    self.status == 'attempting'
  end

  def submitted?
    self.status == 'submitted'
  end

  def graded?
    self.status == 'graded'
  end

  def get_asm
    self.training
  end

  def get_path
    course_training_training_submission_path(training.course, training, self)
  end

  def get_new_grading_path
    '#'
  end

  def done?
    #if a training chanage between can skip and cannot, we will have problem
    #if we check done by position
    #if training.can_skip?
    questions_left == []
    #else
    #  current_step > self.training.asm_qns.count
    #end
  end

  def questions_left
    assessment.questions - answered_questions
  end

  #TODO
  def answered_questions
    answers = sbm_answers.map {|sba| sba.answer }
    answers.select {|a| a.answer_grading }.map {|a| a.qn}.uniq
  end

  def update_grade
    self.submit_at = DateTime.now
    self.current_step = training.asm_qns.count + 1
    self.set_graded

    pending_action = std_course.pending_actions.where(item_type: Training.to_s, item_id: self.training).first
    pending_action.set_done if pending_action

    subm_grading = self.get_final_grading
    subm_grading.update_grade
    exp = subm_grading.update_exp_transaction
    subm_grading.save
    exp
  end

  #TODO
  # def assignment
  #   training
  # end
end