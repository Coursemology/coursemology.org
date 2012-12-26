class StdMcqAnswer < ActiveRecord::Base
  attr_accessible :choices, :mcq_answer_id, :mcq_id, :student_id

  scope :final, where(is_final: true)

  belongs_to :student, class_name: "User"
  belongs_to :mcq
  belongs_to :mcq_answer

  alias_method :qn, :mcq
end
