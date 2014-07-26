class Question < ActiveRecord::Base
  attr_accessible :creator_id, :description, :max_grade, :title

  include AssessmentModule

  belongs_to :creator, class_name: "User"

  has_many :asm_qns, as: :qn, dependent: :destroy
  has_many :std_answers, dependent: :destroy
end
