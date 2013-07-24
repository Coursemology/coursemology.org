class StdCodingAnswer < ActiveRecord::Base
  include Commentable
  attr_accessible :code, :std_course_id, :student_id, :qn_id

  belongs_to :student, class_name: "User"
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :qn, class_name: "CodingQuestion"

  has_many :comments, as: :commentable
  has_many :annotations, as: :annotable

  has_one :answer_grading, as: :student_answer, dependent: :destroy

  has_many :sbm_answers, as: :answer, dependent: :destroy

  def get_subscribed_user_courses
    ucs = []
    sbm_answers.each do |sbm_ans|
      sbm = sbm_ans.sbm
      ucs << sbm.std_course
      course = sbm.std_course.course
      ucs += course.lect_courses
    end
    ucs.uniq { |uc| uc.id }
  end
end
