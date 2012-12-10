class Answer < ActiveRecord::Base
  attr_accessible :creator_id, :explanation, :is_correct, :question_id, :text

  belongs_to :creator, class_name: "User"
  # Question is actually a polymorphic of Question & MCQ.
  # It can be either of them
  belongs_to :question, polymorphic: true
end
