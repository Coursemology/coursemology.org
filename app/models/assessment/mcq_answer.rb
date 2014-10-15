class Assessment::McqAnswer < ActiveRecord::Base
  acts_as_paranoid
  is_a :answer, as: :as_answer, auto_join: false, class_name: "Assessment::Answer"

  attr_accessible :std_course_id, :question_id, :content, :submission_id, :attempt_left, :correct, :finalised

  has_many  :answer_options, class_name: Assessment::AnswerOption, foreign_key: "answer_id"
  has_many  :options, class_name: Assessment::McqOption, through: :answer_options

  def self.group_by_options
    self.joins("INNER JOIN assessment_answer_options aao
              ON assessment_mcq_answers.id = aao.answer_id").
        select("assessment_mcq_answers.*,  COUNT(option_id) AS count").
        group("aao.option_id").
        order("assessment_mcq_answers.created_at")
  end
end


