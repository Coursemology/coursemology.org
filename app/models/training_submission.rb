class TrainingSubmission < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Sbm

  # current_step starts from 1, not 0
  attr_accessible :current_step, :open_at, :std_course_id, :submit_at, :training_id

  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :training

  has_many :sbm_answers, as: :sbm
  has_many :std_mcq_answers, through: :sbm_answers,
      source: :answer, source_type: "StdMcqAnswer"

  has_many :submission_gradings, as: :sbm

  def get_asm
    return self.training
  end

  def get_path
    return course_training_training_submission_path(training.course, training, self)
  end

  def get_new_grading_path
    return '#'
  end
end
