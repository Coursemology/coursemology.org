class Assignment < ActiveRecord::Base
  attr_accessible :attempt_limit, :auto_graded, :course_id, :close_at, :creator_id, :deadline,
    :description, :exp, :open_at, :order, :timelimit, :title

  belongs_to :course
  belongs_to :creator, class_name: "User"

  has_many :asm_qns, as: :asm
  has_many :mcqs, through: :asm_qns, source: :qn, source_type: "Mcq"
  has_many :questions, through: :asm_qns, source: :qn, source_type: "Question"
  has_many :submissions

  def update_grade
    self.max_grade = self.mcqs.sum(&:max_grade) + self.questions.sum(&:max_grade)
    self.save
  end
end
