class QuestionAssessment < ActiveRecord::Base

  belongs_to :assessment
  #TOFIX, if we put depend: :destroy here, what will happen if question is pointed to multiple assessments
  belongs_to :question
end