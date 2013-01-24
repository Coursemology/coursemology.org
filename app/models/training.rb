class Training < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  # Assignments may have other assignment as requirement
  # Not implemented yet.
  include HasRequirement
  include ActivityObject
  include Assignment

  attr_accessible :course_id, :creator_id, :description, :exp, :max_grade, :open_at, :pos, :title

  belongs_to :creator, class_name: "User"
  belongs_to :course

  has_many :mcqs, through: :asm_qns, source: :qn, source_type: "Mcq"
  has_many :training_submissions, dependent: :destroy

  def update_grade
    self.max_grade = self.mcqs.sum(&:max_grade)
    self.save
  end

  def get_path
    return course_training_path(course, self)
  end

  alias_method :sbms, :training_submissions
end
