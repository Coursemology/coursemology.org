class StdAnswer < ActiveRecord::Base
  include Commentable

  attr_accessible :question_id, :student_id, :text

  belongs_to :student, class_name: "User"
  belongs_to :question

  has_many :comments, as: :commentable

  has_many :sbm_answers, as: :answer, dependent: :destroy

  alias_method :qn, :question

  def get_subscribed_user_courses
    ucs = []
    sbm_answers.each do |sbm_ans|
      sbm = sbm_ans.sbm
      ucs << sbm.std_course
      course = sbm.std_course.course
      ucs += course.lect_courses
    end
    return ucs.uniq { |uc| uc.id }
  end

  def get_url
    return sbm_answers.first.sbm.get_url
  end
end
