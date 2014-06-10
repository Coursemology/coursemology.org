class StdAnswer < ActiveRecord::Base
  # TODO: may need to store more information in the std_answer
  # in case a question is linked to more than one mission

  attr_accessible :question_id, :std_course_id, :student_id, :text

  belongs_to :student, class_name: "User"
  belongs_to :question
  belongs_to :std_course, class_name: "UserCourse"

  has_many :sbm_answers, as: :answer, dependent: :destroy
  has_one :comment_topic, as: :topic

  alias_method :qn, :question

  def get_url
    sbm_answers.first.sbm.get_url
  end

  def qn_id
    self.question_id
  end

end
