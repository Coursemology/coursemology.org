class SurveyMrqAnswer < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :user_course_id, :question_id, :option_id

  belongs_to :user_course
  belongs_to :question, class_name: "SurveyQuestion"
  belongs_to :option, class_name: "SurveyQuestionOption"

end
