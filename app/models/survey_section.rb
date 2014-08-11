class SurveySection < ActiveRecord::Base
  acts_as_paranoid
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

  def self.reordering(new_order)
    new_order.each_with_index do |id, index|
      orderable = self.find_by_id(id)
      orderable.pos = index
      orderable.save
    end
  end
end
