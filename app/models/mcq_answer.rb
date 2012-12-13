class McqAnswer < ActiveRecord::Base
  attr_accessible :creator_id, :explanation, :is_correct, :mcq_id, :text

  belongs_to :creator, class_name: "User"
  belongs_to :mcq
end
