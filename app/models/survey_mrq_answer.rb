class SurveyMrqAnswer < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :selected_options, :user_course_id, :question_id

  belongs_to :user_course
  belongs_to :question, class_name: "SurveyQuestion"

  def options
    SurveyQuestionOption.where(id: eval(selected_options))
  end
end
