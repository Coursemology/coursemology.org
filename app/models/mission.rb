class Mission < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  # Assignments may have other assignment as requirement
  # Not implemented yet.
  include HasRequirement
  include ActivityObject
  include Assignment

  attr_accessible :attempt_limit, :auto_graded, :course_id, :close_at, :creator_id, :deadline,
    :description, :exp, :open_at, :pos, :timelimit, :title

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :questions, through: :asm_qns, source: :qn, source_type: "Question"
  has_many :submissions, dependent: :destroy

  def update_grade
    self.max_grade = self.questions.sum(&:max_grade)
    self.save                                            w
  end

  def get_path
    course_mission_path(course, self)
  end

  alias_method :sbms, :submissions
end
