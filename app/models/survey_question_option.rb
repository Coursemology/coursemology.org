class SurveyQuestionOption < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :question_id, :description, :pos

  belongs_to :survey_question, foreign_key: "question_id"
  has_one :file, as: :owner, class_name: "FileUpload", dependent: :destroy

end
