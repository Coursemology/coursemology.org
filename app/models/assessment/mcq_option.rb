class Assessment::McqOption < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :correct, :text, :explanation

  belongs_to :question, class_name: Assessment::Question
  has_many   :answer_options, class_name: Assessment::AnswerOption

  def uniq_std(course)
    course.user_courses.student.
        joins("INNER JOIN assessment_answers aa ON aa.std_course_id = user_courses.id").
        joins("INNER JOIN assessment_answer_options aao ON aao.answer_id = aa.id").
        where("aao.option_id = ?", self.id)
  end
end