class QuizSubmission < ActiveRecord::Base
  include Sbm

  attr_accessible :attempt, :open_at, :quiz_id, :student_id, :submit_at

  scope :final, where(is_final: true)

  belongs_to :quiz
  belongs_to :student, class_name: "User"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :submission_gradings, as: :sbm

  has_many :sbm_answers, as: :sbm
  has_many :std_mcq_answers, through: :sbm_answers,
      source: :answer, source_type: "StdMcqAnswer"

  def self.all_course(course)
    puts 'all ', course.to_json
    subs = QuizSubmission.all
    # TODO: filter by course
    return subs
  end

  def self.all_student(course, student)
    subs = QuizSubmission.all
    # TODO: filter by student and course
    return subs
  end

  # implement method of the Sbm interface
  def get_asm
    return self.quiz
  end
end
