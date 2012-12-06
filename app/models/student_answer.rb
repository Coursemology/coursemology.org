class StudentAnswer < ActiveRecord::Base
  attr_accessible :answer_id, :note, :started_at, :student_id, :submitted_at, :text

  belongs_to :answer
  belongs_to :student, class_name: "User"
end
