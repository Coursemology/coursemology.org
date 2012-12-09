class StudentAnswer < ActiveRecord::Base
  attr_accessible :answer_id, :answerable_id, :answerable_type, :note, :started_at, :student_id, :submitted_at, :text

  belongs_to :answer
  belongs_to :answerable, polymorphic: true
  belongs_to :student, class_name: "User"
  belongs_to :submission
end
