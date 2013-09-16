class SurveySection < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :survey_id, :title, :description, :pos

  belongs_to :survey
  has_many :survey_questions
end
