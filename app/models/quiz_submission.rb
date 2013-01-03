class QuizSubmission < ActiveRecord::Base
  include Sbm

  attr_accessible :attempt, :open_at, :quiz_id, :std_course_id, :submit_at

  scope :final, where(is_final: true)

  belongs_to :quiz
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :submission_gradings, as: :sbm

  has_many :sbm_answers, as: :sbm
  has_many :std_mcq_answers, through: :sbm_answers,
      source: :answer, source_type: "StdMcqAnswer"

  # implement method of the Sbm interface
  def get_asm
    return self.quiz
  end
end
