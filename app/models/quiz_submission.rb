class QuizSubmission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  attr_accessible :attempt, :open_at, :quiz_id, :std_course_id, :submit_at

  scope :final, where(is_final: true)

  belongs_to :quiz
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :std_mcq_answers, through: :sbm_answers,
      source: :answer, source_type: "StdMcqAnswer"

  # implement method of the Sbm interface
  def get_asm
    return self.quiz
  end

  def get_path
    return course_quiz_quiz_submission_path(quiz.course, quiz, self)
  end

  def get_new_grading_path
    return '#'
    # return new_course_quiz_quiz_submission_submission_grading_path(
    #  quiz.course, quiz, self)
  end

end
