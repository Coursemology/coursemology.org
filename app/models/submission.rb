class Submission < ActiveRecord::Base
  attr_accessible :assignment_id, :attempt, :final_grading_id, :open_at, :student_id, :submit_at

  belongs_to :assignment
  belongs_to :student, class_name: "User"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :submission_gradings

  has_many :sbm_answers, as: :sbm
  has_many :std_answers, through: :sbm_answers,
      source: :answer, source_type: "StdAnswer"
  has_many :std_mcq_answers, through: :sbm_answers,
      source: :answer, source_type: "StdMcqAnswer"

  def self.all_course(course)
    puts 'all ', course.to_json
    subs = Submission.all
    # TODO: filter by course
    return subs
  end

  def self.all_student(course, student)
    subs = Submission.all
    # TODO: filter by student and course
    return subs
  end
end
