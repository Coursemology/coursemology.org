class SurveySection < ActiveRecord::Base
  acts_as_paranoid
  acts_as_duplicable
  acts_as_sortable column: :pos
  default_scope { order(:pos) }

  attr_accessible :survey_id, :title, :description, :pos

  belongs_to :survey
  has_many :survey_questions

  amoeba do
    include_field :survey_questions
  end

  def questions
    survey_questions
  end
end
