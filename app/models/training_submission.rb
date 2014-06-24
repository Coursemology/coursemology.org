class TrainingSubmission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  # current_step starts from 1, not 0
  attr_accessible :current_step, :multiplier, :open_at, :std_course_id, :submit_at, :training_id, :status

  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :training

  has_many :std_mcq_answers, through: :sbm_answers,
           source: :answer, source_type: "StdMcqAnswer"

  has_many :std_mcq_all_answers, through: :sbm_answers,
           source: :answer, source_type: "StdMcqAllAnswer"

  has_many :std_coding_answers, through: :sbm_answers,
           :source => :answer, :source_type => "StdCodingAnswer"

  default_scope includes(:std_course)

  def get_asm
    self.training
  end

  def get_path
    course_assessment_training_training_submission_path(training.course, training, self)
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
    training.questions - answered_questions
  end

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

  def assignment
    training
  end

  #def status
  #  if self.submission_gradings.count > 0
  #    "Auto graded"
  #  else
  #    "Pending"
  #  end
  #end

  #def graded?
  #  if self.submission_gradings.count > 0
  #    true
  #  else
  #    false
  #  end
  #end
end
