class Mcq < ActiveRecord::Base
  attr_accessible :assignment_id, :correct_answer_id, :creator_id, :description, :order

  belongs_to :assignment
  belongs_to :creator

  has_many :answers, as: :question
  has_one :correct_answer, class_name: "Answer"
end
