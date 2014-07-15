class StdMcqAllAnswer < ActiveRecord::Base
  attr_accessible :choices, :mcq_id, :selected_choices, :std_course_id, :student_id, :is_correct

  belongs_to :student, class_name: "User"
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :mcq

  has_one :answer_grading, as: :student_answer, dependent: :destroy

  has_many :sbm_answers, as: :answer, dependent: :destroy

  alias_method :qn, :mcq

  def mcq_answers
    McqAnswer.where(:id => eval(selected_choices))
  end

  def qn_id
    mcq_id
  end
end
