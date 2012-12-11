class Mcq < ActiveRecord::Base
  attr_accessible :assignment_id, :correct_answer_id, :creator_id, :description, :max_grade, :order

  belongs_to :assignment
  belongs_to :creator, class_name: "User"

  has_many :answers, as: :question
  has_many :student_answers, as: :answerable
  has_one :correct_answer, class_name: "Answer"
end
