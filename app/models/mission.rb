class Mission < ActiveRecord::Base
  include Assignment

  attr_accessible :attempt_limit, :auto_graded, :course_id, :close_at, :creator_id, :deadline,
    :description, :exp, :open_at, :pos, :timelimit, :title

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :asm_qns, as: :asm
  has_many :questions, through: :asm_qns, source: :qn, source_type: "Question"
  has_many :submissions

  has_many :requirements, as: :obj
  has_many :asm_reqs, through: :requirements, source: :req, source_type: "AsmReq"

  def update_grade
    self.max_grade = self.questions.sum(&:max_grade)
    self.save
  end
end
