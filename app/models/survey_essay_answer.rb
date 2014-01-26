class SurveyEssayAnswer < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :user_course_id, :question_id, :text, :survey_submission_id

  belongs_to :user_course
  belongs_to :question, class_name: "SurveyQuestion"
  belongs_to :survey_submission

end
