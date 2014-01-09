class SurveySection < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order(:pos) }

  attr_accessible :survey_id, :title, :description, :pos

  belongs_to :survey
  has_many :survey_questions

  def questions
    survey_questions
  end
end
