class SurveyEssayAnswer < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :user_course_id, :question_id, :text

  belongs_to :user_course
  belongs_to :question, class_name: "SurveyQuestion"

end
