class Answer < ActiveRecord::Base
  attr_accessible :creator_id, :explanation, :question_id, :text

  belongs_to :creator, class_name: "User"
  belongs_to :question, polymorphic: true
end
