class Mcq < ActiveRecord::Base
  attr_accessible :correct_answer_id, :creator_id, :description, :max_grade, :order

  belongs_to :creator, class_name: "User"

  has_many :mcq_answers, dependent: :destroy
  has_many :std_mcq_answers, dependent: :destroy
  has_many :asm_qns, as: :qn, dependent: :destroy
end
