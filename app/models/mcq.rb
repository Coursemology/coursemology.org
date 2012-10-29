class Mcq < ActiveRecord::Base
  attr_accessible :assignment_id, :correct_answer_id, :creator_id, :description, :order
end
