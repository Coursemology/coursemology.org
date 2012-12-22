class Submission < ActiveRecord::Base
  include Sbm

  attr_accessible :attempt, :final_grading_id, :mission_id, :open_at, :student_id, :submit_at

  belongs_to :mission
  belongs_to :student, class_name: "User"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :submission_gradings, as: :sbm

  has_many :sbm_answers, as: :sbm
  has_many :std_answers, through: :sbm_answers,
      source: :answer, source_type: "StdAnswer"

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

  # implement method of Sbm interface
  def get_asm
    return self.mission
  end
end
