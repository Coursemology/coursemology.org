class StdCodingAnswer < ActiveRecord::Base
  include Commentable
  attr_accessible :code, :std_course_id, :student_id, :qn_id

  belongs_to :student, class_name: "User"
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :qn, class_name: "CodingQuestion"

  has_many  :comments, as: :commentable, dependent: :destroy
  has_many  :annotations, as: :annotable, dependent: :destroy
  has_one   :pending_comments, as: :answer, dependent: :destroy
  has_one   :answer_grading, as: :student_answer, dependent: :destroy
  has_many  :sbm_answers, as: :answer, dependent: :destroy

  def question
    qn
  end

end
