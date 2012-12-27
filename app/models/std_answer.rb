class StdAnswer < ActiveRecord::Base
  attr_accessible :question_id, :student_id, :text

  belongs_to :student, class_name: "User"
  belongs_to :question

  alias_method :qn, :question
end
