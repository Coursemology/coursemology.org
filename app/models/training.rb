class Training < ActiveRecord::Base
  include Assignment

  attr_accessible :course_id, :creator_id, :description, :exp, :max_grade, :open_at, :order, :title

  has_many :asm_qns, as: :asm
  has_many :mcqs, through: :asm_qns, source: :qn, source_type: "Mcq"
  has_many :training_submissions

  belongs_to :creator, class_name: "User"

  def update_grade
    self.max_grade = self.mcqs.sum(&:max_grade)
    self.save
  end
end
