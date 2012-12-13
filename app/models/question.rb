class Question < ActiveRecord::Base
  attr_accessible :creator_id, :description, :max_grade, :order

  belongs_to :assignment
  belongs_to :creator, class_name: "User"
end
