class Submission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  attr_accessible :attempt, :final_grading_id, :mission_id, :open_at, :std_course_id, :submit_at

  belongs_to :mission
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :final_grading, class_name: "SubmissionGrading"

  has_many :std_answers, through: :sbm_answers,
      source: :answer, source_type: "StdAnswer"

  scope :graded, lambda { where("final_grading_id IS NOT NULL") }

  # implement method of Sbm interface
  def get_asm
    return self.mission
  end

  def get_path
    return course_mission_submission_path(mission.course, mission, self)
  end

  def get_edit_path
    return edit_course_mission_submission_path(mission.course, mission, self)
  end

  def get_new_grading_path
    return new_course_mission_submission_submission_grading_path(
      mission.course, mission, self)
  end
end
