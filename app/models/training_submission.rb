class TrainingSubmission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  # current_step starts from 1, not 0
  attr_accessible :current_step, :multiplier, :open_at, :std_course_id, :submit_at, :training_id

  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :training

  has_many :std_mcq_answers, through: :sbm_answers,
           source: :answer, source_type: "StdMcqAnswer"

  has_many :std_coding_answers, through: :sbm_answers,
           :source => :answer, :source_type => "StdCodingAnswer"

  def get_asm
    return self.training
  end

  def get_path
    return course_training_training_submission_path(training.course, training, self)
  end

  def get_new_grading_path
    return '#'
  end

  def done?
    return current_step > self.training.questions.count
  end

  def update_grade
    subm_grading = self.get_final_grading
    subm_grading.update_grade
    subm_grading.update_exp_transaction
    subm_grading.save
  end

  def status
    if self.submission_gradings.count > 0
      "Auto graded"
    else
      "Pending"
    end
  end

  def graded?
    if self.submission_gradings.count > 0
      true
    else
      false
    end
  end
end
