class SurveyMrqAnswer < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :user_course_id, :question_id, :option_id, :selected_options

  belongs_to :user_course
  belongs_to :question, class_name: "SurveyQuestion"
  belongs_to :option, class_name: "SurveyQuestionOption"

  def options
    SurveyQuestionOption.where(id: eval(selected_options))
  end

end
