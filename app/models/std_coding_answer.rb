class StdCodingAnswer < ActiveRecord::Base
  attr_accessible :code, :student_id, :qn_id

  belongs_to :student, class_name: "User"
  belongs_to :qn, class_name: "CodingQuestion"

  has_one :answer_grading, as: :student_answer, dependent: :destroy

end
