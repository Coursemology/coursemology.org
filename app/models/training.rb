class Training < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :description, :exp, :max_grade, :open_at, :order, :title

  has_many :asm_qns, as: :asm
  has_many :mcqs, through: :asm_qns, source: :qn, source_type: "Mcq"
end
