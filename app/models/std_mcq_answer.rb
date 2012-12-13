class StdMcqAnswer < ActiveRecord::Base
  attr_accessible :choices, :mcq_answer_id, :mcq_id, :student_id

  belongs_to :student, class_name: "User"
  belongs_to :mcq
end
