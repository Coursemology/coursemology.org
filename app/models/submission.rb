class Submission < ActiveRecord::Base
  attr_accessible :assignment_id, :attempt, :open_at, :student_id, :submit_at

  belongs_to :assignment
  belongs_to :student, class_name: "User"

  has_many :student_answers
end
