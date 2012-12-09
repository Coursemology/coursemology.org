class Question < ActiveRecord::Base
  attr_accessible :assignment_id, :creator_id, :description, :order

  belongs_to :assignment
  belongs_to :creator, class_name: "User"

  has_many :answers, as: :question
end
